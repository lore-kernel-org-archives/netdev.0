From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [Alacrityvm-devel] [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 16:21:37 -0500
Message-ID: <b233dd490912231321p5e09946at5ea63cb0d0fa1489@mail.gmail.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org>
	 <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com>
	 <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu>
	 <20091223101340.GC20539@basil.fritz.box> <4B31EF65.6070000@redhat.com>
	 <4B325E33.8060407@gmail.com> <4B327B90.2050403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Avi Kivity <avi@redhat.com>, Andi Kleen <andi@firstfloor.org>,
	kvm@vger.kernel.org,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:45857 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756355AbZLWVVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 16:21:40 -0500
In-Reply-To: <4B327B90.2050403@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Sorry for top post...on a mobile)

When someone repeatedly makes a claim you believe to be wrong and you
correct them, you start to wonder if that person has a less than
honorable agenda.  In any case, I overreacted.  For that, I apologize.

That said, you are still incorrect.  With what I proposed, the model
will run as an in-kernel vbus device, and no longer run in userspace.
It would therefore improve virtio-net as I stated, much in the same
way vhost-net or venet-tap do today.

FYI  I am about to log out for the long holiday, so will be
unresponsive for a bit.

Kind Regards,
-Greg

On 12/23/09, Avi Kivity <avi@redhat.com> wrote:
> On 12/23/2009 08:15 PM, Gregory Haskins wrote:
>> On 12/23/09 5:22 AM, Avi Kivity wrote:
>>
>>
>>> There was no attempt by Gregory to improve virtio-net.
>>>
>> If you truly do not understand why your statement is utterly wrong at
>> this point in the discussion, I feel sorry for you.  If you are trying
>> to be purposely disingenuous, you should be ashamed of yourself.  In any
>> case, your statement is demonstrably bogus, but you should already know
>> this given that we talked about at least several times.
>>
>
> There's no need to feel sorry for me, thanks.  There's no reason for me
> to be ashamed, either.  And there's no need to take the discussion to
> personal levels.  Please keep it technical.
>
>
>> To refresh your memory: http://patchwork.kernel.org/patch/17428/
>>
>
> This is not an attempt to improve virtio-net, it's an attempt to push
> vbus.  With this, virtio-net doesn't become any faster, since the
> greatest bottleneck is not removed, it remains in userspace.
>
> If you wanted to improve virtio-net, you would port venet-host to the
> virtio-net guest/host interface, and port any secret sauce in
> venet(-guest) to virtio-net.  After that we could judge what vbus'
> contribution to the equation is.
>
>> In case its not blatantly clear, which I would hope it would be to
>> anyone that understands the problem space:  What that patch would do is
>> allow an unmodified virtio-net to bridge to a vbus based virtio-net
>> backend.  (Also note that this predates vhost-net by months (the date in
>> that thread is 4/9/2009) in case you are next going to try to argue that
>> it does nothing over vhost-net).
>>
>
> Without the backend, it is useless.  It demonstrates vbus' flexibility
> quite well, but does nothing for virtio-net or its users, at least
> without a lot more work.
>
>> This would mean that virtio-net would gain most of the benefits I have
>> been advocating (fewer exits, cheaper exits, concurrent execution, etc).
>>   So this would very much improve virtio-net indeed, given how poorly the
>> current backend was performing.  I tried to convince the team to help me
>> build it out to completion on multiple occasions, but that request was
>> answered with "sorry, we are doing our own thing instead".  You can say
>> that you didn't like my approach, since that is a subjective opinion.
>> But to say that I didn't attempt to improve it is a flat out wrong, and
>> I do not appreciate it.
>>
>
> Cutting down on the rhetoric is more important than cutting down exits
> at this point in time.
>
> --
> I have a truly marvellous patch that fixes the bug which this
> signature is too narrow to contain.
>
>

-- 
Sent from my mobile device
