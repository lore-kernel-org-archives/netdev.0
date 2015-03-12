From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next] switchdev: correct spelling of notifier in comments
Date: Thu, 12 Mar 2015 10:42:50 +0900
Message-ID: <1426124570-17667-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34713 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbbCLBnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 21:43:10 -0400
Received: by pdno5 with SMTP id o5so15868628pdn.1
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 18:43:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/switchdev/switchdev.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 8cf42a6..b7a23132 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -59,7 +59,7 @@ static DEFINE_MUTEX(netdev_switch_mutex);
 static RAW_NOTIFIER_HEAD(netdev_switch_notif_chain);
 
 /**
- *	register_netdev_switch_notifier - Register nofifier
+ *	register_netdev_switch_notifier - Register notifier
  *	@nb: notifier_block
  *
  *	Register switch device notifier. This should be used by code
@@ -78,7 +78,7 @@ int register_netdev_switch_notifier(struct notifier_block *nb)
 EXPORT_SYMBOL_GPL(register_netdev_switch_notifier);
 
 /**
- *	unregister_netdev_switch_notifier - Unregister nofifier
+ *	unregister_netdev_switch_notifier - Unregister notifier
  *	@nb: notifier_block
  *
  *	Unregister switch device notifier.
@@ -96,7 +96,7 @@ int unregister_netdev_switch_notifier(struct notifier_block *nb)
 EXPORT_SYMBOL_GPL(unregister_netdev_switch_notifier);
 
 /**
- *	call_netdev_switch_notifiers - Call nofifiers
+ *	call_netdev_switch_notifiers - Call notifiers
  *	@val: value passed unmodified to notifier function
  *	@dev: port device
  *	@info: notifier information data
-- 
2.1.4
