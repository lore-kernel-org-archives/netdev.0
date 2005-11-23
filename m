From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [2.6 patch] do not select NET_CLS
Date: Wed, 23 Nov 2005 11:27:10 +0100
Message-ID: <20051123102710.GH20395@postel.suug.ch>
References: <20051116235813.GS5735@stusta.de> <20051121155955.GW16060@stusta.de> <4381F2D2.5000605@trash.net> <20051122.143713.101129339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, bunk@stusta.de, evil@g-house.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	zippel@linux-m68k.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030373AbVKWK0v@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20051122.143713.101129339.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David S. Miller <davem@davemloft.net> 2005-11-22 14:37
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 21 Nov 2005 17:16:18 +0100
> 
> > Adrian Bunk wrote:
> > > This patch therefore changes NET_CLS back to the 2.6.14 status quo of 
> > > being an user-visible option.
> > 
> > I disagree with this patch. NET_CLS enables the infrastructure support
> > for classifiers. Users generally don't care about infrastructure but
> > directly usable things, so I'd prefer to have it automatically selected. 
> > And there are lots of other cases where enabling a module causes changes
> > in the kernel image. Some examples include some of the netfilter stuff,
> > the IPsec transforms, NET_CLS_ROUTE4, the ieee80211 stuff, and a lot
> > more.
> 
> I agree with Patrick.

In fact Patrick's explanation was exactly the motivation for me to
change it in the first place a few weeks back.

I thought about making cls_api aware to be built as module but then
the same would apply for ematches and the generic scheduling code
and it gets real complicated. It is possible with some heavy code
shuffling but not worth it I think.
