From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: kernel panic on 2.6.24 with esfq patch applied
Date: Sat, 02 Feb 2008 10:28:34 +0100
Message-ID: <47A437C2.1030101@gmail.com>
References: <20080201131509.M52958@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:2839 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbYBBJZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 04:25:41 -0500
Received: by ug-out-1314.google.com with SMTP id z38so874962ugc.16
        for <netdev@vger.kernel.org>; Sat, 02 Feb 2008 01:25:40 -0800 (PST)
In-Reply-To: <20080201131509.M52958@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote, On 02/01/2008 02:25 PM:

> Hi
> 
> Probably bug related to ESFQ, now i will unload module and will test more. 
> But probably not related, so if not difficult, please take a look.


Hi,

The main break seems to take place in HTB. Do you use HTB on IFB, BTW?
If not, maybe some exemplary rules from your script? (There are quite
a few modules loaded...)

Thanks,
Jarek P.
