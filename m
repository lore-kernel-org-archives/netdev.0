From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH RFC] tun: experimental zero copy tx support
Date: Tue, 15 May 2012 11:00:00 -0700
Message-ID: <1337104800.8220.25.camel@oc3660625478.ibm.com>
References: <20120513155206.GA26847@redhat.com>
	 <20120514095446.3ce307d2@nehalam.linuxnetplumber.net>
	 <20120514170412.GA17086@redhat.com>
	 <1337022146.8512.606.camel@edumazet-glaptop>
	 <20120514191456.GC17086@redhat.com>
	 <1337023307.8512.617.camel@edumazet-glaptop>
	 <20120514193134.GA18366@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ian.Campbell@citrix.com,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120514193134.GA18366@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-05-14 at 22:31 +0300, Michael S. Tsirkin wrote:
> On Mon, May 14, 2012 at 09:21:47PM +0200, Eric Dumazet wrote:
> > On Mon, 2012-05-14 at 22:14 +0300, Michael S. Tsirkin wrote:
> > 
> > > They seem to be in net-next, or did I miss something?
> > 
> > Yes, you re-introduce in this patch some bugs already fixed in
> macvtap
> 
> Could explain why I see some problems in testing :)
> Maybe common code should go into net/core?
> I couldn't decide whether the increase in kernel
> size is worth it.

Which problem you hit during testing?

The logic of zerocopy_sg_from_iovec should work well. Jason's fix made
the code more clear.

Thanks
Shirley
