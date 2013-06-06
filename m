From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next rfc V3 0/9] Multiqueue API for macvtap
Date: Thu, 06 Jun 2013 11:07:06 +0800
Message-ID: <51AFFCDA.8030707@redhat.com>
References: <1370414192-5830-1-git-send-email-jasowang@redhat.com> <20130605103625.GF31830@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130605103625.GF31830@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/05/2013 06:36 PM, Michael S. Tsirkin wrote:
> On Wed, Jun 05, 2013 at 02:36:23PM +0800, Jason Wang wrote:
>> > Hi all:
>> > 
>> > This series implements a v3 of fully tuntap compatiable API which could be used
>> > by userspace to manage multiple macvtap queues. The main parts is to add
>> > TUNSETQUEUE ioctl support for macvtap.
>> > 
>> > Patch 1 - 5 was some tuntap compatibility and misc cleanups.
>> > Patch 6 removes the linear search in macvtap by reshuffling the macvtaps array
>> > each time a queue is removed. After this, we could store both enabled and
>> > disabled queues in the same array without introducing extra data structure.
>> > Patch 7 let TUNSETIFF can create multiqueue device, nothing but some check
>> > were added.
>> > Patch 8 implement TUNSETQUEUE ioctl
>> > Patch 9 reports IFF_MULTI_QUEUE to userspace to notify the userspace that the
>> > multiqueue API is completed.
>> > 
>> > Flow caches implememtation were missed in this version, since I am doing
>> > rework on the tuntap flow caches. Have some some stress test with both netperf
>> > and pktgen.
>> > 
>> > Please review, thanks.
> FYI by netdev rules RFC means "don't apply yet".
>

Ok, let me remove the rfc in next series.
