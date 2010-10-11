From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Mon, 11 Oct 2010 12:51:27 +0530
Message-ID: <OF6C412DBC.EA03FC24-ON652577B9.00228DCA-652577B9.0028232D@in.ibm.com>
References: <cover.1286372004.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, kvm@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <cover.1286372004.git.mst@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 10/06/2010 07:04:31 PM:

> On Fri, Sep 17, 2010 at 03:33:07PM +0530, Krishna Kumar wrote:
> > For 1 TCP netperf, I ran 7 iterations and summed it. Explanation
> > for degradation for 1 stream case:
>
> I thought about possible RX/TX contention reasons, and I realized that
> we get/put the mm counter all the time.  So I write the following: I
> haven't seen any performance gain from this in a single queue case, but
> maybe this will help multiqueue?

Sorry for the delay, I was sick last couple of days. The results
with your patch are (%'s over original code):

Code               BW%       CPU%       RemoteCPU
MQ     (#txq=16)   31.4%     38.42%     6.41%
MQ+MST (#txq=16)   28.3%     18.9%      -10.77%

The patch helps CPU utilization but didn't help single stream
drop.

Thanks,

- KK

