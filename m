From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 4.4-only] openvswitch: clear sender cpu before
 forwarding packets
Date: Wed, 17 May 2017 10:19:33 +0200
Message-ID: <20170517081933.GA25610@kroah.com>
References: <1494944710-7901-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Anoob Soman <anoob.soman-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1494944710-7901-1-git-send-email-anoob.soman-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2017 at 03:25:10PM +0100, Anoob Soman wrote:
> Similar to commit c29390c6dfee ("xps: must clear sender_cpu before
> forwarding") the skb->sender_cpu needs to be cleared before forwarding
> packets.
> 
> Fixes: 2bd82484bb4c ("xps: fix xps for stacked devices")
> Signed-off-by: Anoob Soman <anoob.soman-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
> ---
>  net/openvswitch/vport.c | 1 +
>  1 file changed, 1 insertion(+)

Why is this a non-upstream patch?  What commit in Linus's tree fixed
this?  Why not just backport that?

thanks,

greg k-h
