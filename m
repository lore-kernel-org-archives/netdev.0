From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/3] network namespaces for generic netlink
Date: Tue, 07 Jul 2009 14:08:36 +0200
Message-ID: <20090707120835.953398074@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Pavel Emelyanov <xemul@openvz.org>, Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:48660 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755387AbZGGMQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 08:16:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a repost of my earlier patches, now with
fixed semantics and locking. The first patch is
required to make RCU-iteration of the network
namespace list possible, which the second patch
requires.

The third patch is preparation for nl80211 netns
work, I'm happy to give that to John instead to
go via the wireless tree with the patch that will
make use of the now exported function, but it is
possible that other generic netlink users will
also require it once they being upgrading their
family to be netns aware.

johannes

