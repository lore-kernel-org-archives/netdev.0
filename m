From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers
Date: Fri, 07 Aug 2009 10:46:24 -0500
Message-ID: <4A7C4C50.5040503@codemonkey.ws>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <20090806081955.GA9752@redhat.com> <4A7C37E5.4040302@codemonkey.ws> <4A7C42C8.5050608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753524AbZHGPq2@vger.kernel.org>
In-Reply-To: <4A7C42C8.5050608@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
> That said, note that the graphs were from earlier kernel runs (2.6.28,
> 29-rc8).  The most recent data I can find that I published is for
> 2.6.29, announced with the vbus-v3 release back in April:
>
> http://lkml.org/lkml/2009/4/21/408
>
> In it, the virtio-net throughput numbers are substantially higher and
> possibly more in line with your expectations (4.5gb/s) (though notably
> still lagging venet, which weighed in at 5.6gb/s).
>   

Okay, that makes more sense.  Would be nice to update the graphs as they 
make virtio look really, really bad :-)

> Generally, I find that the virtio-net exhibits non-deterministic results
> from release to release.  I suspect (as we have discussed) the
> tx-mitigation scheme.  Some releases buffer the daylights out of the
> stream, and virtio gets close(r) throughput (e.g. 4.5g vs 5.8g, but
> absolutely terrible latency (4000us vs 65us).  Other releases it seems
> to operate with more of a compromise (1.3gb/s vs 3.8gb/s, but 350us vs
> 85us).
>   

Are you using kvm modules or a new kernel?  There was some timer 
infrastructure changes around 28/29 and it's possible that the system 
your on is now detecting an hpet which will result in a better time 
source.  That could have an affect on mitigation.

> If there is another patch-series/tree I should be using for comparison,
> please point me at it.
>   

No, I think it's fair to look at upstream Linux.  Looking at the latest 
bits would be nice though because there are some virtio friendly changes 
recently like MSI-x and GRO.

Since you're using the latest vbus bits, it makes sense to compare 
against the latest virtio bits.

Regards,

Anthony Liguori
