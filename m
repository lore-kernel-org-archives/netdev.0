From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/8) arlan -- trailing semicolons.
Date: Thu, 25 Sep 2003 15:59:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925155951.32eeba17.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of extra trailing semicolons

diff -Nru a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
--- a/drivers/net/wireless/arlan-main.c	Thu Sep 25 14:44:10 2003
+++ b/drivers/net/wireless/arlan-main.c	Thu Sep 25 14:44:10 2003
@@ -114,7 +114,7 @@
 	struct timeval timev;
 	do_gettimeofday(&timev);
 	return ((long long) timev.tv_sec * 1000000 + timev.tv_usec);
-};
+}
 
 #ifdef ARLAN_ENTRY_EXIT_DEBUGGING
 #define ARLAN_DEBUG_ENTRY(name) \
@@ -162,7 +162,7 @@
 			netif_wake_queue (dev);
 	}
 	return 1;
-};
+}
 
 
 int arlan_command(struct net_device *dev, int command_p)
@@ -314,7 +314,7 @@
 		if (priv->tx_command_given || priv->rx_command_given)
 		{
 			printk(KERN_ERR "%s: Reset under tx or rx command \n", dev->name);
-		};
+		}
 		netif_stop_queue (dev);
 		if (arlan_debug & ARLAN_DEBUG_RESET)
 			printk(KERN_ERR "%s: Doing chip reset\n", dev->name);
@@ -407,7 +407,7 @@
 			{
 				priv->waiting_command_mask &= ~ARLAN_COMMAND_TBUSY_CLEAR;
 				netif_wake_queue (dev);
-			};
+			}
 	}
 	else if (priv->waiting_command_mask & ARLAN_COMMAND_TX)
 	{
@@ -505,7 +505,7 @@
 	ARLAN_DEBUG_EXIT("arlan_command");
 	return 2;
 
-};
+}
 
 static inline void arlan_command_process(struct net_device *dev)
 {
@@ -616,7 +616,7 @@
 			jiffies - priv->tx_last_sent > 5*HZ ){
 			arlan_command(dev, ARLAN_COMMAND_CLEAN_AND_RESET);		
 			priv->tx_last_cleared = jiffies;
-		};
+		}
 	}
 
 
@@ -1018,7 +1018,7 @@
 	if (check_mem_region(virt_to_phys((void *)memaddr),0x2000 )){
 		// printk(KERN_WARNING "arlan: memory region %lx excluded from probing \n",virt_to_phys((void*)memaddr));
 		return -ENODEV;
-	};
+	}
 	memcpy_fromio(tempBuf, arlan->textRegion, 29);
 	tempBuf[30] = 0;
 
@@ -1358,7 +1358,7 @@
 		priv->ReTransmitRequested++;
 
 	ARLAN_DEBUG_EXIT("arlan_queue_retransmit");
-};
+}
 
 static inline void RetryOrFail(struct net_device *dev)
 {
diff -Nru a/drivers/net/wireless/arlan-proc.c b/drivers/net/wireless/arlan-proc.c
--- a/drivers/net/wireless/arlan-proc.c	Thu Sep 25 14:44:10 2003
+++ b/drivers/net/wireless/arlan-proc.c	Thu Sep 25 14:44:10 2003
@@ -108,7 +108,7 @@
 		default:
 			return "ERROR unknown Diagnostic info reply code ";
 	  }
-};
+}
 
 static const char *arlan_hardware_type_string(struct net_device *dev)
 {
