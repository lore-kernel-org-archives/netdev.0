From: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2.42 1/5] odp: Allow VLAN actions after MPLS
	actions
Date: Mon, 7 Oct 2013 14:41:55 -0700
Message-ID: <20131007214155.GB13984@nicira.com>
References: <1380874200-8981-1-git-send-email-horms@verge.net.au>
	<1380874200-8981-2-git-send-email-horms@verge.net.au>
	<20131004162133.GG29572@nicira.com>
	<20131007063447.GF19926@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131007063447.GF19926-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 07, 2013 at 03:34:47PM +0900, Simon Horman wrote:
> What I have done is to make an incremental patch which:
> 
> 1. Moves the 'vlan_tci' member of strict xlate_in to
>    be the 'final_vlan_tci' member of struct xlate_ctx.
> 
> 2. Moves the 'vlan_tci' local variable of do_xlate_actions()
>    to be the 'next_vlan_tci' member of struct xlate_ctx.
> 
> 3. Restructures the comments surrounding the logic of the vlan_tci
>    code that this patch adds mostly as comments for the new
>    members of struct xlate_ctx. I hope things are (still?) clear.
> 
> For reference, the incremental patch I have so far is as follows.
> I will squash it into this patch before reposting this series.

Thanks a lot, I'll take another look at the series now.
