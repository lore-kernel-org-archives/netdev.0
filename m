From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [1/2] [NET] link_watch: Move link watch list into net_device
Date: Thu, 10 May 2007 15:12:11 -0700
Message-ID: <464398BB.8030606@goop.org>
References: <463F95C3.60407@goop.org>	<20070508121322.GA21647@gondor.apana.org.au>	<464395E5.2090500@goop.org> <20070510.150750.118628150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hch@infradead.org, ak@suse.de,
	akpm@linux-foundation.org, virtualization@lists.osdl.org,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	ian.pratt@xensource.com, Christian.Limpach@cl.cam.ac.uk,
	netdev@vger.kernel.org, jeff@garzik.org,
	shemminge@linux-foundation.org, rusty@rustcorp.com.au,
	Valdis.Kletnieks@vt.edu
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762826AbXEJWMi@vger.kernel.org>
In-Reply-To: <20070510.150750.118628150.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeremy Fitzhardinge <jeremy@goop.org>
> Date: Thu, 10 May 2007 15:00:05 -0700
>
>   
>> Herbert Xu wrote:
>>     
>>> [NET] link_watch: Move link watch list into net_device
>>>
>>> These days the link watch mechanism is an integral part of the
>>> network subsystem as it manages the carrier status.  So it now
>>> makes sense to allocate some memory for it in net_device rather
>>> than allocating it on demand.
>>>       
>> I think there's a problem with one of these two patches.
>>     
>
> Yes, there are :-)
>
> Did you catch the follow-on bug fixes?
>   

Nope.  Guess I got dropped from the cc: list.  Was this on lkml or netdev?

    J
