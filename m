From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 0/2] NETFILTER new target module, HMARK
Date: Thu, 3 Feb 2011 14:34:08 +0100
Message-ID: <1296740050-6311-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: hans@schillstrom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The target allows you to create rules in the "raw" and "mangle" tables
which alter the netfilter mark (nfmark) field within a given range.
First a 32 bit hash value is generated then modulus by <limit> and
finally an offset is added before it's written to nfmark.
Prior to routing, the nfmark can influence the routing method (see
"Use netfilter MARK value as routing key") and can also be used by
other subsystems to change their behaviour.

The mark match can also be used to match nfmark produced by this module.
See the kernel module for more info.

REVISION

This is version 1

Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
