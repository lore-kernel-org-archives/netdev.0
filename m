From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH v1 1/2] ethtool: minor doc update
Date: Thu, 17 Mar 2016 17:03:55 -0700
Message-ID: <1458259436-85275-2-git-send-email-ddecotig@gmail.com>
References: <1458259436-85275-1-git-send-email-ddecotig@gmail.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Decotigny <decot@googlers.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Edward Cree <ecree@solarflare.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Florian Westphal <fw@strlen.de>,
	David Herrmann <dh.herrmann@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458259436-85275-1-git-send-email-ddecotig@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

Updates: commit 793cf87de9d1 ("ethtool: Set cmd field in
         ETHTOOL_GLINKSETTINGS response to wrong nwords")

Signed-off-by: David Decotigny <decot@googlers.com>
---
 include/uapi/linux/ethtool.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 2835b07..9222db8 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1648,9 +1648,9 @@ enum ethtool_reset_flags {
  *	%ETHTOOL_GLINKSETTINGS: on entry, number of words passed by user
  *	(>= 0); on return, if handshake in progress, negative if
  *	request size unsupported by kernel: absolute value indicates
- *	kernel recommended size and cmd field is 0, as well as all the
- *	other fields; otherwise (handshake completed), strictly
- *	positive to indicate size used by kernel and cmd field is
+ *	kernel expected size and all the other fields but cmd
+ *	are 0; otherwise (handshake completed), strictly positive
+ *	to indicate size used by kernel and cmd field stays
  *	%ETHTOOL_GLINKSETTINGS, all other fields populated by driver. For
  *	%ETHTOOL_SLINKSETTINGS: must be valid on entry, ie. a positive
  *	value returned previously by %ETHTOOL_GLINKSETTINGS, otherwise
-- 
2.8.0.rc3.226.g39d4020
