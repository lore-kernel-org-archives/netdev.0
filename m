From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] scm: fold __scm_send() into scm_send()
Date: Mon, 20 Mar 2006 15:28:38 -0800 (PST)
Message-ID: <20060320.152838.68858441.davem@davemloft.net>
References: <200603201244.58507.netdev@axxeo.de>
	<20060320201802.GS15997@sorel.sous-sol.org>
	<20060320213636.GT15997@sorel.sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cxzhang@watson.ibm.com, netdev@axxeo.de, ioe-lkml@rameria.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964974AbWCTX3r@vger.kernel.org>
To: chrisw@sous-sol.org
In-Reply-To: <20060320213636.GT15997@sorel.sous-sol.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Wright <chrisw@sous-sol.org>
Date: Mon, 20 Mar 2006 13:36:36 -0800

> The point of Catherine's original patch was to make sure there's always
> a security identifier associated with AF_UNIX messages.  So receiver
> can always check it (same as having credentials even w/out sender
> control message passing them).  Now we will have garbage for sid.

I'm seriously considering backing out Catherine's AF_UNIX patch from
the net-2.6.17 tree before submitting it to Linus later today so that
none of this crap goes in right now.

It appears that this needs a lot more sorting out, so for now that's
probably the right thing to do.
