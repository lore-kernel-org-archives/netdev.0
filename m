From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: 08 Aug 2003 17:51:40 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1060379500.1723.214.camel@jzny.localdomain>
References: <200307141045.40999.nf@hipac.org>
	 <1058328537.1797.24.camel@jzny.localdomain> <3F16A0E5.1080007@hipac.org>
	 <1059934468.1103.41.camel@jzny.localdomain> <3F2E5CD6.4030500@hipac.org>
	 <1060012260.1103.380.camel@jzny.localdomain> <3F302E04.1090503@hipac.org>
	 <1060286331.1025.73.camel@jzny.localdomain>
	 <20030807130502.4af9c815.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: nf@hipac.org, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030807130502.4af9c815.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Thu, 2003-08-07 at 16:05, David S. Miller wrote: 
> On 07 Aug 2003 15:58:51 -0400
> jamal <hadi@cyberus.ca> wrote:

> If you input all the keys into the Jenkins hash, how does
> it perform?  Has anyone even tried that and compared it
> to all of these fancy multi-level tree like hash things?

AFAIK, noone has tried it. I will try out at some point. 

> I think Jenkins would work very well for exactly this kind
> of application.  And it's fully available to the entire kernel
> via linux/jhash.h and already in use by other things such
> as the routing cache and the netfilter conntrack code.

A good reason for the multilevel stuff is to support arbitrary packet 
offsets i.e you dont know which bits in the packet you are interested in
ahead of time. Its easy to use hashes when you know that you need to
find example ip src/dst. Since its in the kernel I will look into 
it - but has to meet the arbitrary offset requirement.

cheers,
jamal


