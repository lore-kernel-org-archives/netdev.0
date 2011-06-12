From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] Revert "net: minor cleanup to net_namespace.c."
Date: Sun, 12 Jun 2011 14:39:02 +0300
Message-ID: <20110612113902.GA5398@p183.telecom.by>
References: <20110612110950.GA11321@p183.telecom.by>
 <20110612.042911.1713846819610012420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rlandley@parallels.com, jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60967 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664Ab1FLLjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 07:39:07 -0400
Received: by bwz15 with SMTP id 15so3113982bwz.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 04:39:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110612.042911.1713846819610012420.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 12, 2011 at 04:29:11AM -0700, David Miller wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Sun, 12 Jun 2011 14:09:50 +0300
> 
> > * C/R and other out-of-tree code uses or will use it,
> 
> Submit this with the out-of-tree code that needs it,
> we never cater to external bits like this.

It is not like I'm asking for an ugly knob or something.

net_create() creates netns, and permission checks are done earlier in
some other place.

Why would anyone merge them back, I can't understand.
