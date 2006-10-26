From: neologix@free.fr
Subject: [SOFTMAC] - level of verbosity
Date: Thu, 26 Oct 2006 19:46:48 +0200
Message-ID: <1161884808.4540f488d02d4@imp3-g19.free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:43410 "EHLO smtp5-g19.free.fr")
	by vger.kernel.org with ESMTP id S1423643AbWJZRW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 13:22:57 -0400
Received: from imp3-g19.free.fr (imp3-g19.free.fr [212.27.42.3])
	by smtp5-g19.free.fr (Postfix) with ESMTP id 1EFB727BAF
	for <netdev@vger.kernel.org>; Thu, 26 Oct 2006 19:22:56 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.
I'd just like to know whether it is be possible to reduce the verbosity level of
softmac.
My wireless is working fine, but my logs are polluted by:

/* LOG */

printk: 20 messages suppressed.
SoftMAC: Received deauthentication packet from 00:0a:79:52:84:6c, but that
network is unknown.
SoftMAC: Received deauthentication packet from 00:0a:79:52:84:6c, but that
network is unknown.
SoftMAC: Received deauthentication packet from 00:0a:79:52:84:6c, but that
network is unknown.
SoftMAC: Received deauthentication packet from 00:0a:79:52:84:6c, but that
network is unknown.
SoftMAC: Received deauthentication packet from 00:0a:79:52:84:6c, but that
network is unknown.
SoftMAC: Received deauthentication packet from 00:0a:79:52:84:6c, but that
network is unknown.
SoftMAC: Received deauthentication packet from 00:14:bf:03:40:68, but that
network is unknown.
SoftMAC: Received deauthentication packet from 00:14:bf:03:40:68, but that
network is unknown.
SoftMAC: Received deauthentication packet from 00:14:bf:03:40:68, but that
network is unknown.
SoftMAC: Received deauthentication packet from 00:14:bf:03:40:68, but that
network is unknown.
SoftMAC: Received deauthentication packet from 00:14:bf:03:40:68, but that
network is unknown.
SoftMAC: Received deauthentication packet from 00:14:bf:03:40:68, but that
network is unknown.
SoftMAC: Authentication response received from 00:14:bf:03:40:68 but no queue
item exists.
SoftMAC: Authentication response received from 00:14:bf:03:40:68 but no queue
item exists.
SoftMAC: Authentication response received from 00:14:bf:03:40:68 but no queue
item exists.
SoftMAC: Authentication response received from 00:14:bf:03:40:68 but no queue
item exists.
SoftMAC: Authentication response received from 00:0f:66:b9:3d:4c but no queue
item exists.
SoftMAC: Authentication response received from 00:0f:66:b9:3d:4c but no queue
item exists.
SoftMAC: Authentication response received from 00:0f:66:b9:3d:4c but no queue
item exists.
SoftMAC: Authentication response received from 00:0f:66:b9:3d:4c but no queue
item exists.
SoftMAC: Authentication response received from 00:0f:66:b9:3d:4c but no queue
item exists.
SoftMAC: Received deauthentication packet from 00:0a:79:52:84:6c, but that
network is unknown.

/* LOG */

It's kinda polluting the interesting parts of logs, and furthermore, when it's
actually written to the file, it provokes regular disk activity, which is
really annoying.

It built my kernel without the softmac debugging option:

$ cat .config | grep SOFTMAC
CONFIG_IEEE80211_SOFTMAC=y
# CONFIG_IEEE80211_SOFTMAC_DEBUG is not set

but it's still really talkative :-)

So, is there anyway to get rid of this?

Anyway, thanks for your work,

cheers,

cf



