From: Florin Malita <fmalita@gmail.com>
Subject: Re: [PATCH] channel bonding: add support for device-indexed
 parameters
Date: Thu, 22 Sep 2005 09:16:08 -0400
Message-ID: <20050922091608.5ec2724c.fmalita@gmail.com>
References: <20050922000444.369c32c2.fmalita@gmail.com>
	<c295378405092123032534d93b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, davem@davemloft.net, ctindel@users.sourceforge.net,
	fubar@us.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030320AbVIVNT0@vger.kernel.org>
To: "Jason R. Martin" <nsxfreddy@gmail.com>
In-Reply-To: <c295378405092123032534d93b@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Sep 2005 23:03:53 -0700
"Jason R. Martin" <nsxfreddy@gmail.com> wrote:
> Personally I think working to get the sysfs support finished in
> bonding and stop relying on module parameters to configure bonds would
> be better, since bonds will truly be independent of each other and be
> able to be added and removed on the fly.  Having worked with a
> previous attempt to set per-bond values through module parameters
> (http://marc.theaimsgroup.com/?t=110558187800001&r=1&w=2), it's easy
> to get pretty crazy.

Agreed - that would be a better configuration interface, but I don't see
why we couldn't support module parameter arrays too. Especially since
the changes are minimal and don't break the ABI/ifenslave
compatibility/etc.

IMHO the "primary" semantics are completely broken right now and this
is a possible fix for it.

> For example, you can have more than one
> arp_ip_target, and they really should be per bond as well, so how do
> you divvy those up via module parameters?

Yup, arp_ip_target is one parameter which doesn't lend itself to this
scheme and this is exactly why the patch doesn't try to fix it.

Florin
