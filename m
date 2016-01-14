From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 2/2] ip-link: fix man page warnings
Date: Thu, 14 Jan 2016 18:10:20 +0100
Message-ID: <1452791420-10771-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1452791420-10771-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Thomas Faivre <thomas.faivre@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:42627 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754704AbcANRLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 12:11:04 -0500
In-Reply-To: <1452791420-10771-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Faivre <thomas.faivre@6wind.com>

grff wrapper returns warnings when parsing the ip-link.8.in file.

How to reproduce:
$ man --warnings ip-link > /dev/null
`R' is a string (producing the registered sign), not a macro.
[...]

Signed-off-by: Thomas Faivre <thomas.faivre@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 man/man8/ip-link.8.in | 102 +++++++++++++++++++++++++-------------------------
 1 file changed, 51 insertions(+), 51 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index a3d90f796a67..02aabcbeb0a5 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -284,28 +284,28 @@ the following additional arguments are supported:
 .BI link " DEVICE "
 .BI name " NAME "
 .BI type " vlan "
-.R " [ "
+[
 .BI protocol " VLAN_PROTO "
-.R " ] "
+]
 .BI id " VLANID "
-.R " [ "
+[
 .BR reorder_hdr " { " on " | " off " } "
-.R " ] "
-.R " [ "
+]
+[
 .BR gvrp " { " on " | " off " } "
-.R " ] "
-.R " [ "
+]
+[
 .BR mvrp " { " on " | " off " } "
-.R " ] "
-.R " [ "
+]
+[
 .BR loose_binding " { " on " | " off " } "
-.R " ] "
-.R " [ "
+]
+[
 .BI ingress-qos-map " QOS-MAP "
-.R " ] "
-.R " [ "
+]
+[
 .BI egress-qos-map " QOS-MAP "
-.R " ] "
+]
 
 .in +8
 .sp
@@ -386,44 +386,44 @@ the following additional arguments are supported:
 
 .BI "ip link add " DEVICE
 .BI type " vxlan " id " ID"
-.R " [ "
+[
 .BI dev " PHYS_DEV "
 .RB " ] [ { " group " | " remote " } "
 .I IPADDR
-.R " ] [ "
+] [
 .B local
 .RI "{ "IPADDR " | "any " } "
-.R " ] [ "
+] [
 .BI ttl " TTL "
-.R " ] [ "
+] [
 .BI tos " TOS "
-.R " ] [ "
+] [
 .BI dstport " PORT "
-.R " ] [ "
+] [
 .BI srcport " MIN MAX "
-.R " ] [ "
+] [
 .I "[no]learning "
-.R " ] [ "
+] [
 .I "[no]proxy "
-.R " ] [ "
+] [
 .I "[no]rsc "
-.R " ] [ "
+] [
 .I "[no]l2miss "
-.R " ] [ "
+] [
 .I "[no]l3miss "
-.R " ] [ "
+] [
 .I "[no]udpcsum "
-.R " ] [ "
+] [
 .I "[no]udp6zerocsumtx "
-.R " ] [ "
+] [
 .I "[no]udp6zerocsumrx "
-.R " ] [ "
+] [
 .BI ageing " SECONDS "
-.R " ] [ "
+] [
 .BI maxaddress " NUMBER "
-.R " ] [ "
+] [
 .B gbp
-.R " ]"
+]
 
 .in +8
 .sp
@@ -565,17 +565,17 @@ the following additional arguments are supported:
 .BI "ip link add " DEVICE
 .BR type " { gre | ipip | sit } "
 .BI " remote " ADDR " local " ADDR
-.R " [ "
+[
 .BR encap " { fou | gue | none } "
-.R " ] [ "
+] [
 .BI "encap-sport { " PORT " | auto } "
-.R " ] [ "
+] [
 .BI "encap-dport " PORT
-.R " ] [ "
+] [
 .I " [no]encap-csum "
-.R " ] [ "
+] [
 .I " [no]encap-remcsum "
-.R " ]"
+]
 
 .in +8
 .sp
@@ -621,25 +621,25 @@ the following additional arguments are supported:
 
 .BI "ip link add " DEVICE
 .BI type " { ip6gre | ip6gretap }  " remote " ADDR " local " ADDR
-.R " [ "
+[
 .I "[i|o]seq]"
-.R " ] [ "
+] [
 .I "[i|o]key" KEY
-.R " ] [ "
+] [
 .I " [i|o]csum "
-.R " ] [ "
+] [
 .BI hoplimit " TTL "
-.R " ] [ "
+] [
 .BI encaplimit " ELIM "
-.R " ] [ "
+] [
 .BI tclass " TCLASS "
-.R " ] [ "
+] [
 .BI flowlabel " FLOWLABEL "
-.R " ] [ "
+] [
 .BI "dscp inherit"
-.R " ] [ "
+] [
 .BI dev " PHYS_DEV "
-.R " ]"
+]
 
 .in +8
 .sp
@@ -744,11 +744,11 @@ the following additional arguments are supported:
 
 .BI "ip link add " DEVICE
 .BI type " geneve " id " ID " remote " IPADDR"
-.R " [ "
+[
 .BI ttl " TTL "
-.R " ] [ "
+] [
 .BI tos " TOS "
-.R " ]"
+]
 
 .in +8
 .sp
-- 
2.4.2
