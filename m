From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: af_packet vs virtio
Date: Fri, 14 Apr 2017 05:42:59 +0300
Message-ID: <20170414051304-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47820 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752432AbdDNCnA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 22:43:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all, I wanted to raise the question of similarities between virtio
and new zero copy af_packet interfaces.

First I would like to mention that virtio device development isn't spec
limited - spec is there to help interoperability and add peace of mind
for people worried about IPR.

So I tend to accept patches without requiring people write it up in the
spec as work on spec proceeds at its own pace - all I ask is that the
virtio mailing list is copied, this requires contributor to subscribe
and in the process contributor promises that it's ok for us to add this
to spec in the future.

There shouldn't thus be a fundamental problem preventing use of virtio
format or reusing some of the code for af_packet, but it still might or
might not make sense - it was designed for CPU to CPU communication so
it seems to make sense though.  So I would like that discussion to
happen even if we decide against.

And even if people decide against, the problem space is very similar.  You
can look up packed ring layout proposal v2 - should I repost here?  Our
prototyping shows significant performance improvements from using it as
compared to head/tail layout.

To start this discission I'm going to reply to this email reposting a
copy of the simplified virtio layout that might be appropriate for
af_packet as well.

-- 
MST
