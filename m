From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: reset transport header if it was not
 set before transmission
Date: Tue, 19 Mar 2013 05:13:54 -0700
Message-ID: <1363695234.21184.36.camel@edumazet-glaptop>
References: <1363333305-54398-1-git-send-email-jasowang@redhat.com>
	 <1363333305-54398-2-git-send-email-jasowang@redhat.com>
	 <1363399851.29475.52.camel@edumazet-glaptop>
	 <20130317.121318.1869489921021513474.davem@davemloft.net>
	 <51482F55.8020900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, edumazet@google.com
To: Jason Wang <jasowang@redhat.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51482F55.8020900@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-03-19 at 17:26 +0800, Jason Wang wrote:
> On 03/18/2013 12:13 AM, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Fri, 15 Mar 2013 19:10:51 -0700
> >
> >> Any way we can avoid adding this to fast path, for people not using
> >> macvtap and ixgbe ?
> > Likewise I'd rather see macvtap be responsible for fixing this up by
> > setting the transport header properly, and therfore sending well
> > formed packets to the rest of the stack.
> 
> Ok, haven't checked all other possibility but looks like packet needs to
> be fixed also.

Daniel, could you post your patches if ready ?

Jason, I believe you could reuse existing flow dissector once Daniel
patches are in.
