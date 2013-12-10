From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: ifconfig doesn't show assignment ip-addresses
Date: Tue, 10 Dec 2013 11:57:41 +0100
Message-ID: <20131210105741.GA2469@minipsycho.orion>
References: <20131209153238.GA10317@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:57746 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328Ab3LJK5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 05:57:44 -0500
Received: by mail-ea0-f177.google.com with SMTP id n15so2153283ead.8
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 02:57:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131209153238.GA10317@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Dec 09, 2013 at 04:32:39PM CET, alex.aring@gmail.com wrote:
>Hi,
>
>On current net-next with a lowpan interface created with:
>
>ip link add link wpan0 name lowpan0 type lowpan
>
>I don't see any ipv6 addresses in ifconfig anymore. The addresses exist,
>because I can ping my device.


Can you see the address in "ip a" ? Would you send me output of
"ifconfig" and "ip a" please? Is this a problem for lowpan only or do
you see this with other device types as well?

>
>I bisect this issue on commit:
>479840ffdbe4242e8a25349218c8e0859223aa35
>
>Does anybody know what's going up there?
>
>- Alex
