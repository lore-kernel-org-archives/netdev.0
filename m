From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tty tree with the net tree
Date: Thu, 29 Apr 2010 15:56:55 +1000
Message-ID: <20100429155655.479e0982.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Alan Cox <alan@linux.intel.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

Today's linux-next merge of the tty tree got a conflict in
include/linux/tty.h between commit
9b27105b4a44c54bf91ecd7d0315034ae75684f7 ("net-caif-driver: add CAIF
serial driver (ldisc)") from the net tree and commit
39658c58ebb52fe7a3488fd520aa89c75721fd20 ("tty: n_gsm line discipline")
from the tty tree.

I used number 21 for the n_gsm line discipline (see below) and 30 for
NR_LDISCS and can carry this fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/linux/tty.h
index bb44fa9,bd5acb7..0000000
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@@ -47,7 -47,8 +47,8 @@@
  #define N_SLCAN		17	/* Serial / USB serial CAN Adaptors */
  #define N_PPS		18	/* Pulse per Second */
  #define N_V253		19	/* Codec control over voice modem */
 -#define N_GSM0710	20	/* GSM 0710 Mux */
 -
 +#define N_CAIF		20      /* CAIF protocol for talking to modems */
++#define N_GSM0710	21	/* GSM 0710 Mux */
  
  /*
   * This character is the same as _POSIX_VDISABLE: it cannot be used as
