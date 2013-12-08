From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] add support for IFA_FLAGS nl attribute
Date: Sun,  8 Dec 2013 12:16:08 +0100
Message-ID: <1386501370-9007-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, bcrl@kvack.org, gaofeng@cn.fujitsu.com,
	joe@perches.com, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:53740 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753245Ab3LHLQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 06:16:15 -0500
Received: by mail-ee0-f47.google.com with SMTP id e51so1026326eek.6
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 03:16:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As this was recently added for ipv6, add it for the rest of occurences
as requested by DaveM.

Jiri Pirko (2):
  dn_dev: add support for IFA_FLAGS nl attribute
  ipv4: add support for IFA_FLAGS nl attribute

 include/linux/inetdevice.h |  2 +-
 include/net/dn_dev.h       |  2 +-
 net/decnet/dn_dev.c        | 13 +++++++++----
 net/ipv4/devinet.c         |  8 ++++++--
 4 files changed, 17 insertions(+), 8 deletions(-)

-- 
1.8.3.1
