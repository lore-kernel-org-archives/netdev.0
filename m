From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Fix memory leak in
 ovs_vport_alloc() error path
Date: Tue, 12 Aug 2014 14:26:34 -0700 (PDT)
Message-ID: <20140812.142634.745490008512171538.davem@davemloft.net>
References: <1407828477-10287-1-git-send-email-cj@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: cj-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1407828477-10287-1-git-send-email-cj-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Christoph Jaeger <cj-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Date: Tue, 12 Aug 2014 09:27:57 +0200

> ovs_vport_alloc() bails out without freeing the memory 'vport' points to.
> 
> Picked up by Coverity - CID 1230503.
> 
> Fixes: 5cd667b0a4 ("openvswitch: Allow each vport to have an array of 'port_id's.")
> Signed-off-by: Christoph Jaeger <cj-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>

Applied, thanks.
