From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: kill useless *switch* defaults
Date: Sun, 14 Feb 2016 22:56:33 +0300
Message-ID: <2512597.mgWUpMzAO5@wasted.cogentembedded.com>
References: <2504091.pf4fyK11eg@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:35651 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbcBNT4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2016 14:56:36 -0500
Received: by mail-lb0-f178.google.com with SMTP id bc4so68395784lbc.2
        for <netdev@vger.kernel.org>; Sun, 14 Feb 2016 11:56:36 -0800 (PST)
In-Reply-To: <2504091.pf4fyK11eg@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver often has the *default* cases doing nothing in the *switch*
statements with  the integer expressions -- remove them.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   12 ------------
 1 file changed, 12 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -500,8 +500,6 @@ static void sh_eth_set_rate_gether(struc
 	case 1000: /* 1000BASE */
 		sh_eth_write(ndev, GECMR_1000, GECMR);
 		break;
-	default:
-		break;
 	}
 }
 
@@ -592,8 +590,6 @@ static void sh_eth_set_rate_r8a777x(stru
 	case 100:/* 100BASE */
 		sh_eth_modify(ndev, ECMR, ECMR_ELB, ECMR_ELB);
 		break;
-	default:
-		break;
 	}
 }
 
@@ -658,8 +654,6 @@ static void sh_eth_set_rate_sh7724(struc
 	case 100:/* 100BASE */
 		sh_eth_modify(ndev, ECMR, ECMR_RTM, ECMR_RTM);
 		break;
-	default:
-		break;
 	}
 }
 
@@ -698,8 +692,6 @@ static void sh_eth_set_rate_sh7757(struc
 	case 100:/* 100BASE */
 		sh_eth_write(ndev, 1, RTRATE);
 		break;
-	default:
-		break;
 	}
 }
 
@@ -767,8 +759,6 @@ static void sh_eth_set_rate_giga(struct
 	case 1000: /* 1000BASE */
 		sh_eth_write(ndev, 0x00000020, GECMR);
 		break;
-	default:
-		break;
 	}
 }
 
@@ -2917,8 +2907,6 @@ static const u16 *sh_eth_get_register_of
 	case SH_ETH_REG_FAST_SH3_SH2:
 		reg_offset = sh_eth_offset_fast_sh3_sh2;
 		break;
-	default:
-		break;
 	}
 
 	return reg_offset;
