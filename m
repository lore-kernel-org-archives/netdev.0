From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Mon, 17 Aug 2009 18:13:25 +0300
Message-ID: <4A897395.9090104@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Gregory Haskins <ghaskins@novell.com>,
	kvm@vger.kernel.org, alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55155 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595AbZHQPNp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2009 11:13:45 -0400
In-Reply-To: <4A8971A8.2040102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2009 06:05 PM, Gregory Haskins wrote:
> Hi Ingo,
>
> 1) First off, let me state that I have made every effort to propose this
> as a solution to integrate with KVM, the most recent of which is April:
>
> http://lkml.org/lkml/2009/4/21/408
>
> If you read through the various vbus related threads on LKML/KVM posted
> this year, I think you will see that I made numerous polite offerings to
> work with people on finding a common solution here, including Michael.
>
> In the end, Michael decided that go a different route using some of the
> ideas proposed in vbus + venet-tap to create vhost-net.  This is fine,
> and I respect his decision.  But do not try to pin "fracturing" on me,
> because I tried everything to avoid it. :)
>    

Given your post, there are only three possible ways to continue kvm 
guest driver development:

- develop virtio/vhost, drop vbus/venet
- develop vbus/venet, drop virtio
- develop both

Developing both fractures the community.   Dropping virtio invalidates 
the installed base and Windows effort.  There were no strong technical 
reasons shown in favor of the remaining option.


> Since I still disagree with the fundamental approach of how KVM IO
> works,

What's that?

> Prior to my effort, KVM was humming along at the status quo and I came
> along with a closer eye and almost doubled the throughput and cut
> latency by 78%.  Given an apparent disagreement with aspects of my
> approach, Michael went off and created a counter example that was
> motivated by my performance findings.
>    

Oh, virtio-net performance was a thorn in our side for a long time.  I 
agree that venet was an additional spur.

> Therefore, even if Avi ultimately accepts Michaels vhost approach
> instead of mine, Linux as a hypervisor platform has been significantly
> _improved_ by a little friendly competition, not somehow damaged by it.
>    

Certainly, and irqfd/ioeventfd are a net win in any case.

> 4) Lastly, these patches are almost entirely just stand alone Linux
> drivers that do not affect KVM if KVM doesn't wish to acknowledge them.
>   Its just like any of the other numerous drivers that are accepted
> upstream into Linux every day.  The only maintained subsystem that is
> technically touched by this series is netdev, and David Miller already
> approved of the relevant patch's inclusion:
>
> http://lkml.org/lkml/2009/8/3/505
>
> So with all due respect, where is the problem?  The patches are all
> professionally developed according to the Linux coding standards, pass
> checkpatch, are GPL'ed, and work with a freely available platform which
> you can download today
> (http://git.kernel.org/?p=linux/kernel/git/ghaskins/alacrityvm/linux-2.6.git;a=summary)
>    

As I mentioned before, I have no technical objections to the patches, I 
just wish the effort could be concentrated in one direction.

-- 
error compiling committee.c: too many arguments to function

