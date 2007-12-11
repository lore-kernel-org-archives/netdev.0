From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: htb and UDP packages bigger than 1500
Date: Tue, 11 Dec 2007 09:19:29 +0100
Message-ID: <20071211081929.GA2261@ff.dom.local>
References: <200712101810.50730.arekm@maven.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Arkadiusz Miskiewicz <arekm@maven.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:16021 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbXLKIO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 03:14:29 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1218562nfb
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 00:14:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200712101810.50730.arekm@maven.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-12-2007 18:10, Arkadiusz Miskiewicz wrote:
> Hello,
> 
> I noticed that HTB doesn't properly limit traffic if someone sends UDP 
> packages bigger than 1500. 
> 
> Does HTB have some problems/known limits in this area?
> 
> There is other traffic in that class and when I drop udp packets bigger than 
> 1500 then remaining traffic is limited properly to correct value.
> 

Should work with proper "mtu" parameter (tc qdisc add htb help) or,
for kernels >= 2.6.23, even without this. If this doesn't help,
probably more information is required.

Regards,
Jarek P.
