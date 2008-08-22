From: Julius Volz <juliusv@google.com>
Subject: [PATCH 0/2] IPVS: Merge AH and ESP support into one file
Date: Fri, 22 Aug 2008 14:06:11 +0200
Message-ID: <1219406773-19357-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, vbusam@google.com, sven.wegener@stealer.net,
	brian.haley@hp.com
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches remove the duplication between ip_vs_proto_ah.c and
ip_vs_proto_esp.c by merging the same functionality into one file,
ip_vs_proto_ah_esp.c.

The original files are almost 100% identical, except for names,
constants, etc., which either referenced AH or ESP. This was brought
up by Brian Haley when I duplicated even more in those files in the
IPVS IPv6 patches. Maybe there's some interest in keeping the files
apart though, so feel free to ignore this then.

Julius
