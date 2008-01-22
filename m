From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: [PATCH] [AF_X25]: constify function pointer tables
Date: Tue, 22 Jan 2008 20:52:04 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801222051460.5722@fbirervta.pbzchgretzou.qr>
References: <54038cd4f87a03884e4f59f8f3697889dfb63c54.1201030614.git.jengelh@computergmbh.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:37099 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbYAVTwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 14:52:05 -0500
In-Reply-To: <54038cd4f87a03884e4f59f8f3697889dfb63c54.1201030614.git.jengelh@computergmbh.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>
---
 net/x25/x25_proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/x25/x25_proc.c b/net/x25/x25_proc.c
index 7d55e50..3faec8e 100644
--- a/net/x25/x25_proc.c
+++ b/net/x25/x25_proc.c
@@ -287,7 +287,7 @@ static const struct file_operations x25_seq_route_fops = {
 	.release	= seq_release,
 };
 
-static struct file_operations x25_seq_forward_fops = {
+static const struct file_operations x25_seq_forward_fops = {
 	.owner		= THIS_MODULE,
 	.open		= x25_seq_forward_open,
 	.read		= seq_read,
-- 
1.5.3.4

