From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 v2] tc: Show classes in tree view
Date: Tue, 23 Dec 2014 00:19:29 +0200
Message-ID: <20141222221929.GA21942@angus-think.lan>
References: <1419263518-14434-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:58474 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753715AbaLVW3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 17:29:35 -0500
Received: by mail-lb0-f169.google.com with SMTP id p9so4596469lbv.0
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 14:29:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1419263518-14434-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2014 at 05:51:58PM +0200, Vadim Kochan wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Added new '-t[ree]' which shows classes dependency
> in the tree view. Meanwhile only generic stats info
> is supported.
> 

Seems here is one limitation with this code so that it will not pick child
classes from the leaf classfull qdisc.
