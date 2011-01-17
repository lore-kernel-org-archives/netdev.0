From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] dummy: do not create a link (dummy0) at module init by
	default
Date: Mon, 17 Jan 2011 09:25:56 +0000
Message-ID: <20110117092556.GA7934@ff.dom.local>
References: <1295225393-5779-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53358 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326Ab1AQJ0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 04:26:03 -0500
Received: by fxm20 with SMTP id 20so5770195fxm.19
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 01:26:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1295225393-5779-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-01-17 01:49, David Ward wrote:
> When the dummy network driver is initialized with no parameters, a link
> is automatically created (named 'dummy0'). This is inconsistent with
> other virtual network drivers such as veth, macvlan, and macvtap, which
> do not create a link upon initialization.

Actually, this is consistent with _other_ virtual network drivers such
as loopback, ifb, and teql, which create a link upon initialization ;-)

Jarek P.
