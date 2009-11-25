From: Rudy Matela <rudy.matela@gmail.com>
Subject: [PATCH] Frame Relay/DLCI coding style corrections.
Date: Wed, 25 Nov 2009 11:01:52 -0300
Message-ID: <20091125140152.GA11436@vacuum.larces.uece.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org
To: mike.mclagan@linux.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758806AbZKYODm@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frame Relay/DLCI coding style corrections.

Added a space separating some keywords (if/while) from the following
parenthesis to conform to the CodingStyle.

Signed-off-by: Rudy Matela <rudy.matela@gmail.com>
---

diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 15d353f..421d071 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -77,7 +77,7 @@ static int dlci_header(struct sk_buff *skb, struct net_device *dev,
 	dlp = netdev_priv(dev);
 
 	hdr.control = FRAD_I_UI;
-	switch(type)
+	switch (type)
 	{
 		case ETH_P_IP:
 			hdr.IP_NLPID = FRAD_P_IP;
@@ -130,7 +130,7 @@ static void dlci_receive(struct sk_buff *skb, struct net_device *dev)
 		dev->stats.rx_errors++;
 	}
 	else
-		switch(hdr->IP_NLPID)
+		switch (hdr->IP_NLPID)
 		{
 			case FRAD_P_PADDING:
 				if (hdr->NLPID != FRAD_P_SNAP)
@@ -208,7 +208,7 @@ static int dlci_config(struct net_device *dev, struct dlci_conf __user *conf, in
 
 	if (!get)
 	{
-		if(copy_from_user(&config, conf, sizeof(struct dlci_conf)))
+		if (copy_from_user(&config, conf, sizeof(struct dlci_conf)))
 			return -EFAULT;
 		if (config.flags & ~DLCI_VALID_FLAGS)
 			return(-EINVAL);
@@ -222,7 +222,7 @@ static int dlci_config(struct net_device *dev, struct dlci_conf __user *conf, in
 
 	if (get)
 	{
-		if(copy_to_user(conf, &dlp->config, sizeof(struct dlci_conf)))
+		if (copy_to_user(conf, &dlp->config, sizeof(struct dlci_conf)))
 			return -EFAULT;
 	}
 
@@ -238,7 +238,7 @@ static int dlci_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	dlp = netdev_priv(dev);
 
-	switch(cmd)
+	switch (cmd)
 	{
 		case DLCI_GET_SLAVE:
 			if (!*(short *)(dev->dev_addr))
@@ -417,7 +417,7 @@ static int dlci_ioctl(unsigned int cmd, void __user *arg)
 	if (!capable(CAP_NET_ADMIN))
 		return(-EPERM);
 
-	if(copy_from_user(&add, arg, sizeof(struct dlci_add)))
+	if (copy_from_user(&add, arg, sizeof(struct dlci_add)))
 		return -EFAULT;
 
 	switch (cmd)
@@ -426,7 +426,7 @@ static int dlci_ioctl(unsigned int cmd, void __user *arg)
 			err = dlci_add(&add);
 
 			if (!err)
-				if(copy_to_user(arg, &add, sizeof(struct dlci_add)))
+				if (copy_to_user(arg, &add, sizeof(struct dlci_add)))
 					return -EFAULT;
 			break;
 
