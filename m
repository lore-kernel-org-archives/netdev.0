From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v2 6/8] net: veth: extend link mode support to 48 bits
Date: Mon,  5 Jan 2015 18:54:08 -0800
Message-ID: <1420512850-24699-7-git-send-email-ddecotig@gmail.com>
References: <1420512850-24699-1-git-send-email-ddecotig@gmail.com>
Cc: David Decotigny <decot@googlers.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Ben Hutchings <ben@decadent.org.uk>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Flavio Leitner <fbl@redhat.com>, Tom Gundersen <teg@jklm.no>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: Amir Vadai <amirv@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420512850-24699-1-git-send-email-ddecotig@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/veth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8ad5965..902e127 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -49,8 +49,8 @@ static struct {
 
 static int veth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	cmd->supported		= 0;
-	cmd->advertising	= 0;
+	ethtool_cmd_supported_set(cmd, 0);
+	ethtool_cmd_advertising_set(cmd, 0);
 	ethtool_cmd_speed_set(cmd, SPEED_10000);
 	cmd->duplex		= DUPLEX_FULL;
 	cmd->port		= PORT_TP;
-- 
2.2.0.rc0.207.ga3a616c
