From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 locks up in 2.6.16.5
Date: Tue, 18 Apr 2006 01:09:27 +0200
Message-ID: <20060417230927.GA8893@electric-eye.fr.zoreil.com>
References: <20060415204716.GA1755@jupiter.toms.net> <20060416005821.GA9821@electric-eye.fr.zoreil.com> <20060416134201.GA2681@jupiter.toms.net> <20060416144354.GA11433@electric-eye.fr.zoreil.com> <20060416172639.GA12243@jupiter.toms.net> <20060416195327.GA14173@electric-eye.fr.zoreil.com> <20060416225843.GA2274@jupiter.toms.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:51367 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750964AbWDQXNx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 19:13:53 -0400
To: "Thomas A. Oehser" <tom@toms.net>
Content-Disposition: inline
In-Reply-To: <20060416225843.GA2274@jupiter.toms.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas A. Oehser <tom@toms.net> :
[...]
> Ok, here it all is, the attached archive has:
> 
> - .before is right after the interface came up
> - .mid is after flooding it with ping -f commands from 2 machines at once
> - .bad is after doing the cpio over nc that killed it after 170MB
> - .back is after ifconfig down / ifconfig up that restored it

Thanks for the report. It is quite clear. The device is (almost surely)
killed by a rx fifo overflow. Expect a patch shortly.

I wonder why it overflows in the first place though. How much time does
the 170 Mb transfer need ?

-- 
Ueimor
