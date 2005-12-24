From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] forcedeth: fix random memory scribbling bug
Date: Sat, 24 Dec 2005 10:09:31 -0500
Message-ID: <43AD64AB.2070306@pobox.com>
References: <43AD4ADC.8050004@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, Ayaz Abdulla <AAbdulla@nvidia.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <43AD4ADC.8050004@colorfullife.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred Spraul wrote:
> Two critical bugs were found in forcedeth 0.47:
> - TSO doesn't work.
> - pci_map_single() for the rx buffers is called with size==0. This bug 
> is critical, it causes random memory corruptions on systems with an iommu.
> 
> Below is a minimal fix for both bugs, for inclusion into 2.6.15.
> TSO will be fixed properly in the next version.
> Tested on x86-64.
> 
> Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>

1) Why does forcedeth require a non-standard calculation for each 
pci_map_single() call?

2) I have requested multiple times that you avoid MIME...

3) Why disable TSO completely?  It sounds like it should default to off, 
then permit enabling via ethtool.

	Jeff
