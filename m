From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH iproute2] man: token: fix couple of typos
Date: Wed, 18 Jun 2014 09:40:42 +0200
Message-ID: <1403077242-30386-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14011 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965070AbaFRHkq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 03:40:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not sure how these typos slipped in back then, I suspect
too much coffee. ;) So lets fix them up properly.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 man/man8/ip-token.8 | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/man/man8/ip-token.8 b/man/man8/ip-token.8
index 521596f..35a3d1e 100644
--- a/man/man8/ip-token.8
+++ b/man/man8/ip-token.8
@@ -1,6 +1,6 @@
 .TH IP\-TOKEN 8 "28 Mar 2013" "iproute2" "Linux"
 .SH "NAME"
-ip-token \- tokenized interface identifer support
+ip-token \- tokenized interface identifier support
 .SH "SYNOPSIS"
 .sp
 .ad l
@@ -26,7 +26,7 @@ ip-token \- tokenized interface identifer support
 .BR "ip token" " { " list " }"
 
 .SH "DESCRIPTION"
-IPv6 tokenized interface identifer support is used for assigning well-known
+IPv6 tokenized interface identifier support is used for assigning well-known
 host-part addresses to nodes whilst still obtaining a global network prefix
 from Router advertisements. The primary target for tokenized identifiers are
 server platforms where addresses are usually manually configured, rather than
@@ -41,13 +41,13 @@ set the interface token to the kernel. Once a token is set, it cannot be
 removed from the interface, only overwritten.
 .TP
 .I TOKEN
-the interface identifer token address.
+the interface identifier token address.
 .TP
 .BI dev " DEV"
 the networking interface.
 
 .SS ip token get - get the interface token from the kernel
-show a tokenized interface identifer of a particular networking device.
+show a tokenized interface identifier of a particular networking device.
 .B Arguments:
 coincide with the arguments of
 .B ip token set
@@ -55,7 +55,7 @@ but the
 .I TOKEN
 must be left out.
 .SS ip token list - list all interface tokens
-list all tokenized interface identifers for the networking interfaces from
+list all tokenized interface identifiers for the networking interfaces from
 the kernel.
 
 .SH SEE ALSO
-- 
1.7.11.7
