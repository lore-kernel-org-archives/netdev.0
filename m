From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: [patch 1/4] natsemi: Add support for using MII port with no PHY
Date: Mon, 13 Mar 2006 18:23:31 +0000
Message-ID: <20060313182331.GA19014@sirena.org.uk>
References: <20060312192259.929734000@mercator.sirena.org.uk> <20060312205303.869316000@mercator.sirena.org.uk> <20060312214113.GA15071@hockin.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932321AbWCMS33@vger.kernel.org>
To: thockin@hockin.org
Content-Disposition: inline
In-Reply-To: <20060312214113.GA15071@hockin.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 12, 2006 at 01:41:13PM -0800, thockin@hockin.org wrote:

> Not that my opinion should hold much weight, having been absent from the
> driver for some time, but yuck.  Is there no better way to do this thatn
> sprinkling poo all over it?

The changes are mostly isolated into check_link(), the fact that half
the function gets placed inside a conditional but diff sees it as a
bunch of smaller changes makes the changes look a lot more invasive than
they actually are.  I guess that could be helped by splitting the PHY
access code out of check_link() into check_phy_status() or something but
I'm not sure how much that really helps.

-- 
"You grabbed my hand and we fell into it, like a daydream - or a fever."
