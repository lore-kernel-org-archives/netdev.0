From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 4.4-only] openvswitch: clear sender cpu before
 forwarding packets
Date: Thu, 18 May 2017 10:11:49 +0200
Message-ID: <20170518081149.GA31512@kroah.com>
References: <1494944710-7901-1-git-send-email-anoob.soman@citrix.com>
	<20170517081933.GA25610@kroah.com>
	<371bcd34-10fa-867f-8bfb-7f61caf11cbe@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Anoob Soman <anoob.soman-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <371bcd34-10fa-867f-8bfb-7f61caf11cbe-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
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

On Wed, May 17, 2017 at 10:21:09AM +0100, Anoob Soman wrote:
> On 17/05/17 09:19, Greg KH wrote:
> > Why is this a non-upstream patch?  What commit in Linus's tree fixed
> > this?  Why not just backport that?
> > 
> > thanks,
> > 
> > greg k-h
> 
> Agreed, I think it is sensible to backport 52bd2d62ce67 "net: better
> skb->sender_cpu and skb->napi_id cohabitation" to 4.4, rather than having a
> different patch.

So backporting that one patch solves the issue here?  Can you please
verify it, and let me know before I apply it?

thanks,

greg k-h
