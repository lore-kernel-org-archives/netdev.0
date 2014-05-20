From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH v2.57] datapath: Add basic MPLS support to
	kernel
Date: Tue, 20 May 2014 13:18:37 +0100
Message-ID: <20140520121837.GC23328@casper.infradead.org>
References: <1400195227-21265-1-git-send-email-horms@verge.net.au>
 <1400195227-21265-2-git-send-email-horms@verge.net.au>
 <20140516084809.GA18920@verge.net.au>
 <CAEP_g=-BQJTthV3JbgiiMtCEwM+-YX_sN5VpGkiPQLUVOKP0cg@mail.gmail.com>
 <20140516214806.GH8346@casper.infradead.org>
 <CAEP_g=9JQAqm0oMpVAK-6V-0wtqPw=cRMasJhCG1T5n-AdaLVg@mail.gmail.com>
 <20140517013224.GA25978@verge.net.au>
 <20140519220219.GA20590@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140519220219.GA20590-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

On 05/20/14 at 07:02am, Simon Horman wrote:
> [PATCH] datapath: 16bit inner_network_header field in struct ovs_gso_cb
> 
> The motivation for this is to create a 16bit hole in struct ovs_gso_cb
> which may be used for the inner_protocol field which is needed
> for the proposed implementation of compatibility for MPLS GSO segmentation.
> 
> This should be safe as inner_network_header is now an offset to
> the inner_mac_header rather than skb->head.
> 
> As pointed out by Thomas Graf simply making both inner offsets 16bis is not
> safe as there have been cases of overflow with "with collapsed TCP frames
> on IB when the headroom grew beyond 64K. See commit 50bceae9bd ``tcp:
> Reallocate headroom if it would overflow csum_start'' for additional
> details."
> 
> This patch is based on suggestions by Thomas Graf and Jesse Gross.
> 
> Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> Cc: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

LGTM

Reviewed-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
