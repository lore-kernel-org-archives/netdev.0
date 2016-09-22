From: Derek Fawcus <dfawcus@brocade.com>
Subject: Re: [PATCH] L2TP:Adjust intf MTU, add underlay L3, overlay L2
Date: Thu, 22 Sep 2016 09:53:16 +0100
Message-ID: <20160922085316.GA11264@dfawcus.brocade.com>
References: <ee265b42-893f-39b7-c740-b3e23b5058a2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <kleptog@svana.org>, <jchapman@katalix.com>,
        <mostrows@speakeasy.net>, <acme@xconectiva.com.br>,
        <netdev@vger.kernel.org>, <davem@redhat.com>,
        <linux-kernel@vger.kernel.org>, <nprachan@brocade.com>,
        <rshearma@brocade.com>, <stephen@networkplumber.org>
To: "R. Parameswaran" <parameswaran.r7@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ee265b42-893f-39b7-c740-b3e23b5058a2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 21, 2016 at 02:11:04pm -0700, R. Parameswaran wrote:
> 
[snip]

> @@ -206,6 +209,46 @@ static void l2tp_eth_show(struct seq_file *m, void
> *arg)
>  }
>  #endif
[snip]

> +
>  static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id,
> u32 peer_session_id, struct l2tp_session_cfg *cfg)
>  {
>  	struct net_device *dev;
> @@ -255,11 +298,8 @@ static int l2tp_eth_create(struct net *net, u32
> tunnel_id, u32 session_id, u32 p
>  	}
> 

Your diff has whitespace errors,  probably where your MUA has decided to do
'intelligent' line wrapping.
You should (re)send from a proper MUA which does not suffer from this issue.

DF
