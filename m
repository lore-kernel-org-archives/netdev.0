From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] fix tcp_default_win_scale.
Date: Wed, 7 Jul 2004 15:41:13 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.NEB.4.33.0407071519540.19720-100000@dexter.psc.edu>
References: <20040707110653.7c49bef1@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, bert hubert <ahu@ds9a.nl>,
	<jamie@shareable.org>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040707110653.7c49bef1@dell_ss3.pdx.osdl.net>
List-Id: netdev.vger.kernel.org

On Wed, 7 Jul 2004, Stephen Hemminger wrote:

> I do not argue with that the correct thing to do is to use window scaling
> and find/fix the poor sop's stuck behind busted networks.
>
> But: isn't it better to have just one sysctl parameter set (tcp_rmem)
> and set the window scale as needed rather than increasing the already
> bewildering array of dials and knobs?  I can't see why it would be advantageous
> to set a window scale of 7 if the largest possible window ever offered
> is limited to a smaller value?


I personally agree with this.  One can imagine cases where it would be
useful to have a control on window scale, but the added complexity is
probably not worth it.

  -John




