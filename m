From: Shan Wei <shanwei88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/9] net: openvswitch: use this_cpu_ptr
	per-cpu helper
Date: Fri, 09 Nov 2012 09:39:58 +0800
Message-ID: <509C5EEE.4050205@gmail.com>
References: <5093EE59.8010609@gmail.com>
	<0000013ac23ac528-19a0dd1b-3144-45df-9d6e-471999d6ae31-000000@email.amazonses.com>
	<509BC026.4040209@gmail.com>
	<0000013ae10817d9-c5215352-348f-4898-b618-bb89e8725ab1-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel-Maillist <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <0000013ae10817d9-c5215352-348f-4898-b618-bb89e8725ab1-000000-p/GC64/jrecnJqMo6gzdpkEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Christoph Lameter said, at 2012/11/9 1:18:
> On Thu, 8 Nov 2012, Shan Wei wrote:
> 
>> Christoph Lameter said, at 2012/11/3 1:46:
>>>>  		u64_stats_update_begin(&stats->sync);
>>>>  		stats->tx_packets++;
>>>
>>> Use this_cpu_inc(vport->percpu_stats->packets) here?
>>
>> Lots of network drivers use u64_stats_sync infrastructure for statistics
> 
> So they would all have an advantage from the patch.

I will try to do the optimizing next time in another patchset which not included
in this series patchset.

I will submit v3 version of this series after testing today.

Thanks

 
 
