From: Wei Xu <wexu@redhat.com>
Subject: Re: "virtio-net: enable multiqueue by default" in linux-next breaks
 networking on GCE
Date: Wed, 14 Dec 2016 12:24:43 +0800
Message-ID: <95568017-e7b1-df95-ec49-f38ae8eb1b14@redhat.com>
References: <20161212233343.q5xlv55rc5npqaqp@thunk.org>
 <bb997932-20d2-42f4-0f42-bd28ae151076@redhat.com>
 <20161213194431.42vtozn6bs24vwda@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org, mst@redhat.com,
        nhorman@tuxdriver.com, davem@davemloft.net
To: "Theodore Ts'o" <tytso@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56820 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751913AbcLNEYt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Dec 2016 23:24:49 -0500
In-Reply-To: <20161213194431.42vtozn6bs24vwda@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016年12月14日 03:44, Theodore Ts'o wrote:
> Jason's patch fixed the issue, so I think we have the proper fix, but
> to answer your questions:
>
> On Wed, Dec 14, 2016 at 01:46:44AM +0800, Wei Xu wrote:
>>
>> Q1:
>> Which distribution are you using for the GCE instance?
>
> The test appliance is based on Debian Jessie.
>
>> Q2:
>> Are you running xfs test as an embedded VM case, which means XFS test
>> appliance is also a VM inside the GCE instance? Or the kernel is built
>> for the instance itself?
>
> No, GCE currently doesn't support running nested VM's (e.g., running
> VM's inside GCE).  So the kernel is built for the instance itself.
> The way the test appliance works is that it initially boots using the
> Debian Jessie default kernel and then we kexec into the kernel under
> test.
>
>> Q3:
>> Can this bug be reproduced for kvm-xfstests case? I'm trying to set up
>> a local test bed if it makes sense.
>
> You definitely can't do it out of the box -- you need to build the
> image using "gen-image --networking", and then run "kvm-xfstests -N
> shell" as root.  But the bug doesn't reproduce on kvm-xfstests, using
> a 4.9 host kernel and linux-next guest kernel.
>

OK, thanks a lot.

BTW, although this is a guest issue, is there anyway to view the GCE
host kernel or qemu(if it is) version?

>
> Cheers,
>
> 					- Ted
>
