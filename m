From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH/RFC v4 net-next] ravb: Add dma queue interrupt support
Date: Wed, 27 Jan 2016 10:49:44 +0900
Message-ID: <20160127014944.GD27499@verge.net.au>
References: <1453650775-19886-1-git-send-email-ykaneko0929@gmail.com>
 <20160126002300.GA27856@verge.net.au>
 <56A7C252.3040707@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56A7C252.3040707@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2016 at 10:00:34PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
>    Yoshihiro-san, there was no need to hurry -- net-next is still closed and
> by posting this patch to netdev you're only making DaveM upset...

True.

> On 01/26/2016 03:23 AM, Simon Horman wrote:
> 
> >> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> >>
> >>This patch supports the following interrupts.
> >>
> >>- One interrupt for multiple (descriptor, error, management)
> >>- One interrupt for emac
> >>- Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
> >>
> >>This patch improve efficiency of the interrupt handler by adding the
> >>interrupt handler corresponding to each interrupt source described
> >>above. Additionally, it reduces the number of times of the access to
> >>EthernetAVB IF.
> >>
> >>Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> >>Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> >
> >I have tested this patch and the result seems positive.
> 
>    Tested on gen3 only I guess?

Yes, that is correct.

> >Please let me know if any more/different testing would help.
> 
>    Sanity testing on some gen2 SoC wouldn't hurt (if you have time).

I don't believe that I have access to a gen2 board (+ extra hardware ?)
where ravb works. If you do would it be possible for you to do a sanity
test?
