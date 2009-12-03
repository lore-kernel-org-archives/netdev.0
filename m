From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/3] iproute: fix tc ipt/xt module.
Date: Thu, 03 Dec 2009 08:09:38 -0500
Message-ID: <1259845778.3766.32.camel@bigi>
References: <cover.1259765732.git.andreas@fatal.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:42644 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753821AbZLCNJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 08:09:35 -0500
Received: by vws30 with SMTP id 30so591962vws.33
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 05:09:42 -0800 (PST)
In-Reply-To: <cover.1259765732.git.andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2009-12-02 at 16:10 +0100, Andreas Henriksson wrote:
> The xtables API has changed since the tc xt module was written.
> This mini-series moves the legacy stuff out of the way (kept for
> compatibility with older iptables versions) and starts
> a new fresh xt module.
> 
> Hopefully the xtables api will be kept stable in the future.
> If so, this new xt module should continue working since it only
> uses exposed functions (unlike the old one which had an internal
> header to access internal functions in xtables).
> 
> Andreas Henriksson (3):
>   Keep the old tc/ipt/xt module for compatibility.
>   Add new (iptables 1.4.5 compatible) tc/ipt/xt module.
>   Slightly improve the configure script.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Andreas, in the future can you CC me please - I dont read netdev
in real time (sometimes i catch up in a month and skim over).

cheers,
jamal

