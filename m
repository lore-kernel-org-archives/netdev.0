From: "Eric S. Raymond" <esr@thyrsus.com>
Subject: [PATCH] In tc-ematch.8, remove no-op .ti requests to prevent
 translation warnings
Date: Tue, 9 Jul 2013 20:13:06 -0400
Message-ID: <20130710001306.GA9346@thyrsus.com>
Reply-To: esr@thyrsus.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-71-162-243-5.phlapa.fios.verizon.net ([71.162.243.5]:46840
	"EHLO snark.thyrsus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788Ab3GJANN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 20:13:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These do nothing on an 80-column display. They were clearly somebody's
boilerplate way of setting up hanging indents, but the syntax lines
are way too short to require them. And since most were argumentless
they would have been no-ops on any sized display.
---
 man/man8/tc-ematch.8 | 27 +++++----------------------
 1 file changed, 5 insertions(+), 22 deletions(-)

diff --git a/man/man8/tc-ematch.8 b/man/man8/tc-ematch.8
index 567ce7d..b9bf70c 100644
--- a/man/man8/tc-ematch.8
+++ b/man/man8/tc-ematch.8
@@ -6,54 +6,43 @@ ematch \- extended matches for use with "basic" or "flow" filters
 .SH SYNOPSIS
 .sp
 .ad l
-.in +8
-.ti -8
 .B "tc filter add .. basic match"
 .RI EXPR
 .B .. flowid ..
 .sp
 
-.ti -8
 .IR EXPR " := " TERM " [ { "
 .B and | or
 }
 .IR EXPR
 ]
 
-.ti -8
 .IR TERM " := [ " \fBnot " ] { " MATCH " | '(' " EXPR " ')' } "
 
-.ti -8
 .IR MATCH " := " module " '(' " ARGS " ')' "
 
-.ti -8
 .IR ARGS " := " ARG1 " " ARG2 " ..
 
 .SH MATCHES
 
 .SS cmp
 Simple comparison ematch: arithmetic compare of packet data to a given value.
-.ti
+
 .IR cmp "( " ALIGN " at " OFFSET " [ " ATTRS " ] { " eq " | " lt " | " gt " } " VALUE " )
 
-.ti
 .IR ALIGN " := { " u8 " | " u16 " | " u32 " } "
 
-.ti
 .IR ATTRS " := [ layer " LAYER " ] [ mask " MASK " ] [ trans ]
 
-.ti
 .IR LAYER " := { " link " | " network " | " transport " | " 0..2 " }
 
 .SS meta
 Metadata ematch
-.ti
+
 .IR meta "( " OBJECT " { " eq " | " lt " |" gt " } " OBJECT " )
 
-.ti
 .IR OBJECT " := { " META_ID " |  " VALUE " }
 
-.ti
 .IR META_ID " := " id " [ shift " SHIFT " ] [ mask " MASK " ]
 
 .TP
@@ -78,35 +67,29 @@ A full list of meta attributes can be obtained via
 
 .SS nbyte
 match packet data byte sequence
-.ti
+
 .IR nbyte "( " NEEDLE  " at " OFFSET " [ layer " LAYER " ] )
 
-.ti
 .IR NEEDLE  " := { " string " | " c-escape-sequence "  } "
 
-.ti
 .IR OFFSET  " := " int
 
-.ti
 .IR LAYER " := { " link " | " network " | " transport " | " 0..2 " }
 
 .SS u32
 u32 ematch
-.ti
+
 .IR u32 "( " ALIGN " " VALUE " " MASK " at [ nexthdr+ ] " OFFSET " )
 
-.ti
 .IR ALIGN " := { " u8 " | " u16 " | " u32 " }
 
 .SS ipset
 test packet against ipset membership
-.ti
+
 .IR ipset "( " SETNAME " " FLAGS " )
 
-.ti
 .IR SETNAME " := " string
 
-.ti
 .IR FLAGS " := { " FLAG " [, " FLAGS "] }
 
 The flag options are the same as those used by the iptables "set" match.
-- 
1.8.0.1.g2b06c9a


-- 
		<a href="http://www.catb.org/~esr/">Eric S. Raymond</a>
