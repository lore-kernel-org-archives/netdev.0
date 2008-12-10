From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 8139too in >=2.6.26: SIOCSIFFLAGS: Device or resource busy
Date: Wed, 10 Dec 2008 22:04:35 +0100
Message-ID: <20081210210435.GA30537@electric-eye.fr.zoreil.com>
References: <6f67b0190812100251u511d0aect4d082541977335d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Christoph Gysin <christoph.gysin@fr33z3.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48819 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754953AbYLJVEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 16:04:33 -0500
Content-Disposition: inline
In-Reply-To: <6f67b0190812100251u511d0aect4d082541977335d9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Gysin <christoph.gysin@fr33z3.org> :
[...]
> $ modprobe 8139too use_io=1 debug=1
> $ dmesg
> 8139too Fast Ethernet driver 0.9.28
> eth0: RealTek RTL8139 at 0xcf0580e4, 00:03:2d:0e:8e:75, IRQ 64767     <-- !?

Indeed. Assuming you are using the same kernel .config, can you compare
the dmesg from boot of 2.6.25 against 2.6.26 ?

-- 
Ueimor
