From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] Mobile IPv6 for 2.5.40 (request for kernel inclusion)
Date: Wed, 2 Oct 2002 12:25:37 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210021224350.27873-100000@netcore.fi>
References: <20021002092111.GB17010@morphine.tml.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
   <linux-kernel@vger.kernel.org>, <torvalds@transmeta.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Antti Tuominen <ajtuomin@morphine.tml.hut.fi>
In-Reply-To: <20021002092111.GB17010@morphine.tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I believe MIPL implements an old version of MIPv6 (draft -15 or so).

Or do you support -18 ?

On Wed, 2 Oct 2002, Antti Tuominen wrote:
> Hello Dave, Alexey, and all,
> 
> I am part of the MIPL Mobile IPv6 for Linux Team at Helsinki
> University of Technology, and we have been working on an
> implementation of Mobility Support in IPv6 specification for the past
> 3 years.  Now the code has matured to the point, that we feel
> confident enough to ask for kernel inclusion.
> 
> Our implementation has been to several interop and conformance testing
> events, and has proven to be very compliant and to interoperate with
> all major vendors' implementations.  Code has been tested on several
> UP and SMP configurations, and performs quite well.
> 
> Implementation consists of two kernel modules, changes to IPv6 stack,
> and userspace configuration tools.  First module provides support for
> 6over6 (IPv6 in IPv6) tunneling.  Second module is the Mobile IPv6
> module, and adds support for Mobile IPv6 Correspondent Node, Mobile
> Node, and Home Agent.  IPv6 stack has been modified to provide some
> MIPv6 mandated features as well as hooks to our module.
> 
> Latest code for 2.5 series can be pulled from our public BitKeeper
> repository (parent is http://linux.bkbits.net/linux-2.5): 
> 	bk://bk.mipl.mediapoli.com/linux25-mipl
> 
> Diff against latest BK bits can be downloaded from:
> 	http://www.mipl.mediapoli.com/download/linux-2.5+mipv6.diff
> 
> Latest userspace tools are found at:
> 	bk://bk.mipl.mediapoli.com/mipv6-tools
> 
> More information of the project can be found at our website:
> 	http://www.mipl.mediapoli.com/
> 
> The team continues the development work to have fully RFC compliant
> (when the specification moves to RFC) implementation of Mobile IPv6 in
> the Linux kernel, as well as work on improving the code.
> 
> On behalf of the MIPL Team,
> 
> Antti Tuominen
> 
> 

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
