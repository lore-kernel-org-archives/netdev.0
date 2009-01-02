From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: BUG - 2.4.37 fealnx.c NETDEV WATCHDOG: eth0: transmit timed out
Date: Fri, 2 Jan 2009 19:57:18 +0100
Message-ID: <20090102185718.GB20741@electric-eye.fr.zoreil.com>
References: <3f9a31f40901020640m4a9a63caq9c96ba84ccd64d88@mail.gmail.com> <20090102144813.GA13757@1wt.eu> <3f9a31f40901020748m242c46djf153fbab90eeca60@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, wtarreau@hera.kernel.org,
	kernel-testers@vger.kernel.org, netdev@vger.kernel.org,
	jeff@garzik.org, linux-kernel@vger.kernel.org
To: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42696 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755325AbZABS7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 13:59:18 -0500
Content-Disposition: inline
In-Reply-To: <3f9a31f40901020748m242c46djf153fbab90eeca60@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jaswinder Singh Rajput <jaswinderlinux@gmail.com> :
[..]
> Output of mii-diag -v :
> eth0: 10 Mbit, half duplex, no link
>   product info: vendor 00:00:00, model 0 rev 0
>   basic mode:   10 Mbit, half duplex
>   basic status: no link
>   capabilities:
>   advertising:
> 
> This is the output from very old machine Pentium MMX with Redhat 7.1

Can you check with 'mii-tool -vv eth0' that the mii registers are not
all zeroes ?

-- 
Ueimor
