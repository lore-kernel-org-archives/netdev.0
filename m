From: Daniel Drake <dsd@gentoo.org>
Subject: Re: sky2 1.3-rc1
Date: Fri, 05 May 2006 15:34:19 +0100
Message-ID: <445B626B.1070407@gentoo.org>
References: <1146667951.3056.25.camel@fc5test.deadmoose.com> <20060503120507.4558c675@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bill Hoover <bill@luminescent.com>,
	Thomas Glanzmann <sithglan@stud.uni-erlangen.de>,
	Bertrand Jacquin <beber@gna.org>, micheleschi@libero.it,
	netdev@vger.kernel.org, teppic74@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:27667 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751118AbWEEOSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 10:18:21 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060503120507.4558c675@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Here is a new version that addresses some of the outstanding bugs.
> * There was a race in receive processing that would cause hang
> * Some more support for Yukon Ultra found in dual-core Centrino
>   laptops (I want one of these).
> 
> It does not fix the problems with dual port cards corrupting receive
> data (and possibly memory).
> 
> 	http://developer.osdl.org/shemminger/prototypes/sky2-1.3-rc1.tar.bz2
> 
> If this works for most people, I'll post as separate patches for 2.6.17
> tomorrow.
> 

Barry Shilliday at http://bugs.gentoo.org/132056 reports that 1.3-rc1 
solves his earlier problems introduced in v1.1 are solved. However, it's 
not perfect, as latencies are much higher than they used to be.

v0.15:
64 bytes from 10.0.0.138: icmp_seq=2 ttl=64 time=0.467 ms

v1.3-rc1:
64 bytes from 10.0.0.138: icmp_seq=4 ttl=64 time=32.9 ms

Daniel
