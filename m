From: Avi Kivity <avi@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 14:48:35 +0200
Message-ID: <4B3211A3.1090202@redhat.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <20091223101340.GC20539@basil.fritz.box> <4B31EF65.6070000@redhat.com> <20091223121431.GF20539@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>,
	Chris Wright <chrisw@redhat.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754996AbZLWMtb@vger.kernel.org>
In-Reply-To: <20091223121431.GF20539@basil.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/23/2009 02:14 PM, Andi Kleen wrote:
>> http://www.redhat.com/f/pdf/summit/cwright_11_open_source_virt.pdf
>>
>> See slide 32.  This is without vhost-net.
>>      
> Thanks. Do you also have latency numbers?
>    

No.  Copying Chris.  This was with the tx mitigation timer disabled, so 
you won't see the usual atrocious userspace virtio latencies, but it 
won't be as good as a host kernel implementation since we take a 
heavyweight exit and qemu is pretty unoptimized.

> It seems like there's definitely still potential for improvement
> with messages<4K. But for the large messages they indeed
> look rather good.
>    

There's still a lot of optimization to be done, but I hope this proves 
there is nothing inherently slow about virtio.

-- 
error compiling committee.c: too many arguments to function
