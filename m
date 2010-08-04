From: Florian Mickler <florian@mickler.org>
Subject: Re: linux-next: manual merge of the suspend tree with the net tree
Date: Wed, 4 Aug 2010 07:23:02 +0200
Message-ID: <20100804072302.44b6ec30@schatten.dmk.lab>
References: <20100804131411.85975b86.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	James Bottomley <James.Bottomley@suse.de>,
	mark gross <markgross@thegnar.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100804131411.85975b86.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, 4 Aug 2010 13:14:11 +1000
Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Rafael,
> 
> Today's linux-next merge of the suspend tree got a conflict in
> drivers/net/e1000e/netdev.c between commit
> c128ec29208d410568469bd8bb373b4cdc10912a ("e1000e: register pm_qos
> request on hardware activation") from the net tree and commit
> 82f682514a5df89ffb3890627eebf0897b7a84ec ("pm_qos: Get rid of the
> allocation in pm_qos_add_request()") from the suspend tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.

This is the right fix. Thx.

Cheers,
Flo
