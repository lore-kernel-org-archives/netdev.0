From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] hyperv: netvsc: Neaten netvsc_send_pkt by using a
 temporary
Date: Mon, 31 Jul 2017 10:33:16 -0700
Message-ID: <1501522396.22828.4.camel@perches.com>
References: <963fb1dd54804ccd30b1e1249aad4e55ff8d5300.1501449550.git.joe@perches.com>
         <20170731100521.63ef6120@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        devel@linuxdriverproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170731100521.63ef6120@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-07-31 at 10:05 -0700, Stephen Hemminger wrote:
> On Sun, 30 Jul 2017 14:19:30 -0700 Joe Perches <joe@perches.com> wrote:
> > Repeated dereference of nvmsg.msg.v1_msg.send_rndis_pkt can be
> > shortened by using a temporary.  Do so.
[]
> Looks good, several other places also suffer from to long.variable.name.wordiness.

My suggestion is to identify and fix those when you've time.

> > diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
[]
> > @@ -743,6 +743,7 @@ static inline int netvsc_send_pkt(
> >  	struct sk_buff *skb)
> >  {
> >  	struct nvsp_message nvmsg;
> > +	struct nvsp_1_message_send_rndis_packet *rpkt;
> 
> const?

I suppose.  It's an unusual style in the kernel though.

> This part just changed (got rid of indirection) in net-next.

No worries.
