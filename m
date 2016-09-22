From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: Re: [PATCH] L2TP:Adjust intf MTU, add underlay L3, overlay L2
Date: Thu, 22 Sep 2016 14:19:13 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1609221416340.7768@duvvury30.eng.vyatta.net>
References: <ee265b42-893f-39b7-c740-b3e23b5058a2@gmail.com> <20160922085316.GA11264@dfawcus.brocade.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: "R. Parameswaran" <parameswaran.r7@gmail.com>, kleptog@svana.org,
        jchapman@katalix.com, mostrows@speakeasy.net,
        acme@xconectiva.com.br, netdev@vger.kernel.org, davem@redhat.com,
        linux-kernel@vger.kernel.org, nprachan@brocade.com,
        rshearma@brocade.com, stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160922085316.GA11264@dfawcus.brocade.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 22 Sep 2016, Derek Fawcus wrote:

> On Wed, Sep 21, 2016 at 02:11:04pm -0700, R. Parameswaran wrote:
> > 
> [snip]
> 
> > @@ -206,6 +209,46 @@ static void l2tp_eth_show(struct seq_file *m, void
> > *arg)
> >  }
> >  #endif
> [snip]
> 
> > +
> >  static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id,
> > u32 peer_session_id, struct l2tp_session_cfg *cfg)
> >  {
> >  	struct net_device *dev;
> > @@ -255,11 +298,8 @@ static int l2tp_eth_create(struct net *net, u32
> > tunnel_id, u32 session_id, u32 p
> >  	}
> > 
> 
> Your diff has whitespace errors,  probably where your MUA has decided to do
> 'intelligent' line wrapping.
> You should (re)send from a proper MUA which does not suffer from this issue.
> 
> DF
> 

Reposted the patch fixing this, and after rebasing the patch to the 
dmiller 'net' tree, verified that 'git am -c' applies the reposted patch 
successfully (after email header is removed) - thanks for identifying 
this.

regards,

Ramkumar
