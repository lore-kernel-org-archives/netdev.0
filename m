From: "David S. Miller" <davem@davemloft.net>
Subject: Re: IPSEC
Date: Thu, 10 Mar 2005 18:40:07 -0800
Message-ID: <20050310184007.28eaabd0.davem@davemloft.net>
References: <Pine.LNX.4.61.0503081706560.11525@sorbus2.navaho>
	<422DE487.5020800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: steve@services.navaho.net, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <422DE487.5020800@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 08 Mar 2005 18:44:39 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Steve Hill wrote:
> 
> > then the ESP SA is added and it has the same sequence number (1) as the 
> > AH SA so the AH SA gets deleted.
> > 
> > The xfrm_state_add() function does:
> >         x1 = __xfrm_find_acq_byseq(x->km.seq);
> >         ...
> >         xfrm_state_delete(x1);
> > And this is responsible for deleting the AH SA due to it's matching 
> > sequence number.
> 
> This is a bug in the kernel, __xfrm_find_acq_byseq should only return
> XFRM_STATE_ACQ states. This patch should fix it.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
 
