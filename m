From: Aaron Conole <aconole@redhat.com>
Subject: Re: [PATCH -next 2/2] virtio_net: Read the advised MTU
Date: Thu, 02 Jun 2016 13:06:32 -0400
Message-ID: <f7tmvn3sep3.fsf@redhat.com>
References: <1464882211-18723-1-git-send-email-aconole@redhat.com>
	<1464882211-18723-3-git-send-email-aconole@redhat.com>
	<5750578E.4040406@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5750578E.4040406@hpe.com> (Rick Jones's message of "Thu, 2 Jun
	2016 08:58:06 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Rick,

In the future, please don't cut the list.

Rick Jones <rick.jones2@hpe.com> writes:

> On 06/02/2016 08:43 AM, Aaron Conole wrote:
>> This patch checks the feature bit for the VIRTIO_NET_F_MTU feature. If it
>> exists, read the advised MTU and use it.
>>
>> No proper error handling is provided for the case where a user changes the
>> negotiated MTU. A future commit will add proper error handling. Instead, a
>> warning is emitted if the guest changes the device MTU after previously
>> being given advice.
>
> One of the things I've been doing has been setting-up a cluster
> (OpenStack) with JumboFrames, and then setting MTUs on instance vNICs
> by hand to measure different MTU sizes.  It would be a shame if such a
> thing were not possible in the future.  Keeping a warning if shrinking
> the MTU would be good, leave the error (perhaps) to if an attempt is
> made to go beyond the advised value.

This was cut because it didn't make sense for such a warning to
be issued, but it seems like perhaps you may want such a feature?  I
agree with Michael, after thinking about it, that I don't know what sort
of use the warning would serve.  After all, if you're changing the MTU,
you must have wanted such a change to occur?

-Aaron

> happy benchmarking,
>
> rick jones
