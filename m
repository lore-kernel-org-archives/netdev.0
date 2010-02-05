From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: linux-next: manual merge of the trivial tree with the net tree
Date: Fri, 5 Feb 2010 12:23:06 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1002051216460.15395@pobox.suse.cz>
References: <20100205133747.14ca83f2.sfr@canb.auug.org.au> <20100204.202645.18974249.davem@davemloft.net> <alpine.LNX.2.00.1002050935470.15395@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, adam.buchbinder@gmail.com,
	netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1002050935470.15395@pobox.suse.cz>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 5 Feb 2010, Jiri Kosina wrote:

> > > Today's linux-next merge of the trivial tree got a conflict in 
> > > drivers/net/sfc/mcdi_pcol.h between commit 
> > > 5297a98d5dd6de86fe1e2ffc9ea60cdf59b71443 ("sfc: Update MCDI protocol 
> > > definitions") from the net tree and commit 
> > > 4887b438e6880c73c4b44d868211e70c1f3deaec ("Fix misspelling of 
> > > "successful" and variants in comments") from the trivial tree.
> > > 
> > > I fixed it up (see below) and can carry the fix as necessary.
> > 
> > Ugh, this is the second spelling fix that's hit a conflict
> > in the same exact tree.
> > 
> > Please, submit these things to the subsystem maintainers instead
> > of keeping them together in a totally seperate tree.  That way
> > we won't have to keep fighting these things.
> 
> Well, no problem with that. 
> 
> Some maintainers just don't want to be buggered with such patches though, 
> and I always take care of sending this queue to Linus only when all the 
> trees which had conflict in linux-next are already in (and I do the 
> conflict resolution myself), so this should be exactly zero additional 
> work for subsystem maintainers.
> 
> But if you don't like this, I'll just start refusing all the trivial 
> patches touching net/ and drivers/net/ and will redirect them your way.


Ayway, below is the hunk that I have already dropped from my tree (so that 
conflict in linux-next is gone), please feel free to apply it to your 
tree, and let me known whether you want me to reject all furutre patches 
touching net/ and driver/net/ to be refused on my side and redirected your 
way, or if you are fine with me handling the conflict resolution before I 
push them to Linus.

Thanks.



From: Adam Buchbinder <adam.buchbinder@gmail.com>
Subject: NET: Fix misspelling of "successful" and variants in comments.

Some comments misspell "successful" or variants of the word; this
fixes them. No code changes.

Signed-off-by: Adam Buchbinder <adam.buchbinder@gmail.com>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>

diff --git a/drivers/net/sfc/mcdi_pcol.h b/drivers/net/sfc/mcdi_pcol.h
index 2a85360..f61e1de 100644
--- a/drivers/net/sfc/mcdi_pcol.h
+++ b/drivers/net/sfc/mcdi_pcol.h
@@ -853,7 +853,7 @@
  * Poll for BIST completion
  *
  * Returns a single status code, and a binary blob of phy-specific
- * bist output. If the driver can't succesfully parse the BIST output,
+ * bist output. If the driver can't successfully parse the BIST output,
  * it should still respect the Pass/Fail in OUT.RESULT.
  *
  * Locks required: PHY_LOCK  if doing a  PHY BIST
diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 64cdfeb..40ee5f6 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -1595,7 +1595,7 @@ int i2400m_dev_bootstrap(struct i2400m *i2400m, enum i2400m_bri flags)
 		i2400m->fw_name = fw_name;
 		ret = i2400m_fw_bootstrap(i2400m, fw, flags);
 		release_firmware(fw);
-		if (ret >= 0)	/* firmware loaded succesfully */
+		if (ret >= 0)	/* firmware loaded successfully */
 			break;
 		i2400m->fw_name = NULL;
 	}
diff --git a/drivers/net/wireless/rt2x00/rt2x00link.c b/drivers/net/wireless/rt2x00/rt2x00link.c
index 0efbf5a..ffee9f8 100644
--- a/drivers/net/wireless/rt2x00/rt2x00link.c
+++ b/drivers/net/wireless/rt2x00/rt2x00link.c
@@ -240,7 +240,7 @@ void rt2x00link_update_stats(struct rt2x00_dev *rt2x00dev,
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 
 	/*
-	 * Frame was received successfully since non-succesfull
+	 * Frame was received successfully since non-successful
 	 * frames would have been dropped by the hardware.
 	 */
 	qual->rx_success++;
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index 0a751e7..8b8c500 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -200,7 +200,7 @@ static void rt2x00usb_interrupt_txdone(struct urb *urb)
 	 * Obtain the status about this packet.
 	 * Note that when the status is 0 it does not mean the
 	 * frame was send out correctly. It only means the frame
-	 * was succesfully pushed to the hardware, we have no
+	 * was successfully pushed to the hardware, we have no
 	 * way to determine the transmission status right now.
 	 * (Only indirectly by looking at the failed TX counters
 	 * in the register).
