From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH] scm: fold __scm_send() into scm_send()
Date: Mon, 20 Mar 2006 15:43:38 -0800
Message-ID: <20060320234338.GW15997@sorel.sous-sol.org>
References: <200603201244.58507.netdev@axxeo.de> <20060320201802.GS15997@sorel.sous-sol.org> <20060320213636.GT15997@sorel.sous-sol.org> <20060320.152838.68858441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chrisw@sous-sol.org, cxzhang@watson.ibm.com, netdev@axxeo.de,
	ioe-lkml@rameria.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750741AbWCTXoU@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060320.152838.68858441.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David S. Miller (davem@davemloft.net) wrote:
> From: Chris Wright <chrisw@sous-sol.org>
> Date: Mon, 20 Mar 2006 13:36:36 -0800
> 
> > The point of Catherine's original patch was to make sure there's always
> > a security identifier associated with AF_UNIX messages.  So receiver
> > can always check it (same as having credentials even w/out sender
> > control message passing them).  Now we will have garbage for sid.
> 
> I'm seriously considering backing out Catherine's AF_UNIX patch from
> the net-2.6.17 tree before submitting it to Linus later today so that
> none of this crap goes in right now.
> 
> It appears that this needs a lot more sorting out, so for now that's
> probably the right thing to do.

I won't object.  I checked your tree, it looks OK to me.  The actual
broken patch appears in -mm, and the security_sid_to_context snafu
is primarily cosmetic at this point (the exports, etc fixed the real
compilation issues AFAICT).  But, again, if you want to drop that's fine
w/ me.  I'm sure Catherine can cleanup and resend as needed.

thanks,
-chris
