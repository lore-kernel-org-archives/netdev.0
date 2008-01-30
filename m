From: Adrian Bunk <bunk@kernel.org>
Subject: Strange commit 42a73808ed4f30b739eb52bcbb33a02fe62ceef5
Date: Wed, 30 Jan 2008 19:55:08 +0200
Message-ID: <20080130175508.GC29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764057AbYA3Ryw@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 42a73808ed4f30b739eb52bcbb33a02fe62ceef5
("[RAW]: Consolidate proc interface.") did not only change raw6_seq_ops
(including adding 3 EXPORT_SYMBOL_GPL's to net/ipv4/raw.c for accessing 
functions from there), it also removed the only user of raw6_seq_ops...

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
