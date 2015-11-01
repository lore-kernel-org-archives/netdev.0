From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the spi tree with the net-next tree
Date: Sun, 1 Nov 2015 23:18:35 +1100
Message-ID: <20151101231835.06ea249c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Andrew F. Davis" <afd@ti.com>,
	Javier Martinez Canillas <javier@osg.samsung.com>,
	Samuel Ortiz <sameo@linux.intel.com>
To: Mark Brown <broonie@kernel.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mark,

Today's linux-next merge of the spi tree got a conflict in:

  drivers/nfc/trf7970a.c

between commit:

  3c39c1a54a26 ("NFC: trf7970a: Add OF match table")

from the net-next tree and commit:

  3821a065f567 ("spi: Drop owner assignment from spi_drivers")

from the spi tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/nfc/trf7970a.c
index 123aa981c9d8,4036788c78b6..000000000000
--- a/drivers/nfc/trf7970a.c
+++ b/drivers/nfc/trf7970a.c
@@@ -2229,8 -2223,6 +2229,7 @@@ static struct spi_driver trf7970a_spi_d
  	.id_table	= trf7970a_id_table,
  	.driver		= {
  		.name	= "trf7970a",
 +		.of_match_table = of_match_ptr(trf7970a_of_match),
- 		.owner	= THIS_MODULE,
  		.pm	= &trf7970a_pm_ops,
  	},
  };
