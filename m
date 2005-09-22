From: "Jason R. Martin" <nsxfreddy@gmail.com>
Subject: Re: [PATCH] channel bonding: add support for device-indexed parameters
Date: Wed, 21 Sep 2005 23:03:53 -0700
Message-ID: <c295378405092123032534d93b@mail.gmail.com>
References: <20050922000444.369c32c2.fmalita@gmail.com>
Reply-To: "Jason R. Martin" <nsxfreddy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: akpm@osdl.org, davem@davemloft.net, ctindel@users.sourceforge.net,
	fubar@us.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965235AbVIVGDy@vger.kernel.org>
To: Florin Malita <fmalita@gmail.com>
In-Reply-To: <20050922000444.369c32c2.fmalita@gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/21/05, Florin Malita <fmalita@gmail.com> wrote:
> While originally I was interested in being able to set a different
> primary interface for each bond device (same primary for all bond
> devices doesn't make any sense), most parameters deserve the same
> treatement.
>
> This patch adds support for device indexed module parameter
> arrays instead of the old plain scalars. Mostly module_param
> substitutions and parameter parsing logic tweaking.
[snip]

Personally I think working to get the sysfs support finished in
bonding and stop relying on module parameters to configure bonds would
be better, since bonds will truly be independent of each other and be
able to be added and removed on the fly.  Having worked with a
previous attempt to set per-bond values through module parameters
(http://marc.theaimsgroup.com/?t=110558187800001&r=1&w=2), it's easy
to get pretty crazy.  For example, you can have more than one
arp_ip_target, and they really should be per bond as well, so how do
you divvy those up via module parameters?

Jason
