From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 05 Dec 2005 17:30:54 -0500
Message-ID: <4394BF9E.90303@psc.edu>
References: <200512022253.19029.a1426z@gawab.com>	<200512031646.45332.a1426z@gawab.com>	<4391E4FC.1040200@candelatech.com>	<20051205140057.GC24764@tuxdriver.com>	<20051205174010.GA14101@buici.com> <43947FEB.7020504@unfix.org> <4394BCD5.1060505@psc.edu> <4394BF11.2070205@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeroen Massar <jeroen@unfix.org>, Marc Singer <elf@buici.com>,
	Ben Greear <greearb@candelatech.com>,
	Al Boldi <a1426z@gawab.com>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <4394BF11.2070205@hp.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> That's the discussion related to things like the "Strong ES" (end 
> system) model right?  As such, isn't that discussing what _IP_ may do 
> rather than what ARP may do?  1122 doesn't say much about the 
> interfaces/MAC's that should be part of a given ARP reply.  ARP seems to 
> be RFC 826 and probably others, and the algorithm described in 826 
> doesn't seem to be specific on the topic of interfaces - at least not to 
> my really brief read.
> 
> rick jones

Yes, but if an interface will accept packets for a certain IP address, 
and will send packets with that IP address, is there any reason it can't 
ARP for that address?

   -John
