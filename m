From: Avi Kivity <avi@redhat.com>
Subject: Re: [Alacrityvm-devel] [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Sun, 27 Dec 2009 15:27:46 +0200
Message-ID: <4B3760D2.3080500@redhat.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org>	 <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com>	 <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu>	 <20091223101340.GC20539@basil.fritz.box> <4B31EF65.6070000@redhat.com>	 <4B325E33.8060407@gmail.com> <4B327B90.2050403@redhat.com> <b233dd490912231321p5e09946at5ea63cb0d0fa1489@mail.gmail.com> <4B3725CE.8040004@redhat.com> <4B375EAD.8050204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, kvm@vger.kernel.org,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751874AbZL0N2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Dec 2009 08:28:21 -0500
In-Reply-To: <4B375EAD.8050204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/27/2009 03:18 PM, Gregory Haskins wrote:
> On 12/27/09 4:15 AM, Avi Kivity wrote:
>    
>> On 12/23/2009 11:21 PM, Gregory Haskins wrote:
>>      
>>> That said, you are still incorrect.  With what I proposed, the model
>>> will run as an in-kernel vbus device, and no longer run in userspace.
>>> It would therefore improve virtio-net as I stated, much in the same
>>> way vhost-net or venet-tap do today.
>>>
>>>        
>> That can't work.  virtio-net has its own ABI on top of virtio, for
>> example it prepends a header for TSO information.  Maybe if you disable
>> all features it becomes compatible with venet, but that cripples it.
>>
>>      
> You are confused.  The backend would be virtio-net specific, and would
> therefore understand the virtio-net ABI.  It would support any feature
> of virtio-net as long as it was implemented and negotiated by both sides
> of the link.
>    

Then we're back to square one.  A nice demonstration of vbus 
flexibility, but no help for virtio.

-- 
error compiling committee.c: too many arguments to function

