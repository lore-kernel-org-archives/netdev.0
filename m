From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 6 Oct 2010 15:34:31 +0200
Message-ID: <cover.1286372004.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, davem@davemloft.net, kvm@vger.kernel.org,
	arnd@arndb.de, netdev@vger.kernel.org, avi@redhat.com,
	anthony@codemonkey.ws
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 17, 2010 at 03:33:07PM +0530, Krishna Kumar wrote:
> For 1 TCP netperf, I ran 7 iterations and summed it. Explanation
> for degradation for 1 stream case:

I thought about possible RX/TX contention reasons, and I realized that
we get/put the mm counter all the time.  So I write the following: I
haven't seen any performance gain from this in a single queue case, but
maybe this will help multiqueue?

Thanks,

Michael S. Tsirkin (2):
  vhost: put mm after thread stop
  vhost-net: batch use/unuse mm

 drivers/vhost/net.c   |    7 -------
 drivers/vhost/vhost.c |   16 ++++++++++------
 2 files changed, 10 insertions(+), 13 deletions(-)

-- 
1.7.3-rc1
