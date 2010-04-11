From: kaber@trash.net
Subject: [RFC PATCH 0/9] net: support multiple independant multicast routing instances
Date: Sun, 11 Apr 2010 19:37:06 +0200
Message-ID: <1271007435-20035-1-git-send-email-kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37497 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412Ab0DKRhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 13:37:19 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by stinky.trash.net (Postfix) with ESMTP id 5AE82B2C4C
	for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 19:37:17 +0200 (MEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches add support for multiple independant multicast
routing instances. This can be useful to seperate traffic when building
a multicast router that is serving multiple independant networks. Patch
09 contains a more detailed description of this feature in the changelog.

The patchset consists of the following parts:

- Patch 01 and 02 consolidate a small amount of code in the different
  fib_rules users.

- Patch 03 decouples fib_rules family values from real address families
  to allow using them in code that is not a seperate address family without
  increasing AF_MAX/NPROTO.

- Patch 04 moves the raw_sock/raw_sk() definitions from icmp.h to raw.h
  since they will also be used by ipmr in a following patch.

- Patch 05-08 contain some preparatory work and cleanup for supporting
  multiple multicast routing instances.

- Patch 09 contains the actual changes to support multiple multicast
  routing instances.

These patches have been tested using pimd by myself and using xorp by
Ben Greear.

Comments welcome.

