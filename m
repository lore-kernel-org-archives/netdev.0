From: Aaron Conole <aconole@redhat.com>
Subject: Re: [PATCH] virtio-net: Update the mtu code to match virtio spec
Date: Tue, 25 Oct 2016 16:14:34 -0400
Message-ID: <f7tpomo5gph.fsf@redhat.com>
References: <1477413335-17296-1-git-send-email-aconole@redhat.com>
        <f7ta8ds9ory.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: virtualization@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jarod Wilson <jarod@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52552 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750806AbcJYUOg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Oct 2016 16:14:36 -0400
In-Reply-To: <f7ta8ds9ory.fsf@redhat.com> (Aaron Conole's message of "Tue, 25
        Oct 2016 16:06:41 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aaron Conole <aconole@redhat.com> writes:

>> From: Aaron Conole <aconole@bytheb.org>
>>
>> The virtio committee recently ratified a change, VIRTIO-152, which
>> defines the mtu field to be 'max' MTU, not simply desired MTU.
>>
>> This commit brings the virtio-net device in compliance with VIRTIO-152.
>>
>> Additionally, drop the max_mtu branch - it cannot be taken since the u16
>> returned by virtio_cread16 will never exceed the initial value of
>> max_mtu.
>>
>> Cc: "Michael S. Tsirkin" <mst@redhat.com>
>> Cc: Jarod Wilson <jarod@redhat.com>
>> Signed-off-by: Aaron Conole <aconole@redhat.com>
>> ---
>
> Sorry about the subject line, David.  This is targetted at net-next, and
> it appears my from was mangled.  Would you like me to resubmit with
> these details corrected?

I answered my own question.  Sorry for the noise.
