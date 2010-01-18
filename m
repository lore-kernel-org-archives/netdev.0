From: Li Yewang <lyw@cn.fujitsu.com>
Subject: Re: [PATCH][XFRM] Use the simple  name when adding SAD with ip xfrm
 state
Date: Mon, 18 Jan 2010 16:48:18 +0800
Message-ID: <4B542052.2000409@cn.fujitsu.com>
References: <4B541EE9.9010803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53496 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752606Ab0ARItO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2010 03:49:14 -0500
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id 35E6717011A
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 16:49:13 +0800 (CST)
Received: from fnst.cn.fujitsu.com (tang.cn.fujitsu.com [127.0.0.1])
	by tang.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id o0I8mjES009090
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 16:48:46 +0800
Received: from [127.0.0.1] (unknown [10.167.141.89])
	by fnst.cn.fujitsu.com (Postfix) with ESMTPA id 9270DD473F
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 16:50:15 +0800 (CST)
In-Reply-To: <4B541EE9.9010803@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Li Yewang wrote:
> The encryption name such as "rfc3686(ctr(aes))" is too complex.
> I think simple name is better for user when using "ip xfrm state ..." command.
>  
  sorry for bad patch about previous mail.


  Signed-off-by: Li Yewang <lyw@cn.fujitsu.com>
  
---
 net/xfrm/xfrm_algo.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 743c013..6de2780 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -31,6 +31,7 @@
 static struct xfrm_algo_desc aead_list[] = {
 {
 	.name = "rfc4106(gcm(aes))",
+	.compat = "gcm",
 
 	.uinfo = {
 		.aead = {
@@ -47,6 +48,7 @@ static struct xfrm_algo_desc aead_list[] = {
 },
 {
 	.name = "rfc4106(gcm(aes))",
+	.compat = "gcm",
 
 	.uinfo = {
 		.aead = {
@@ -63,6 +65,7 @@ static struct xfrm_algo_desc aead_list[] = {
 },
 {
 	.name = "rfc4106(gcm(aes))",
+	.compat = "gcm",
 
 	.uinfo = {
 		.aead = {
@@ -79,6 +82,7 @@ static struct xfrm_algo_desc aead_list[] = {
 },
 {
 	.name = "rfc4309(ccm(aes))",
+	.compat = "ccm",
 
 	.uinfo = {
 		.aead = {
@@ -95,6 +99,7 @@ static struct xfrm_algo_desc aead_list[] = {
 },
 {
 	.name = "rfc4309(ccm(aes))",
+	.compat = "ccm",
 
 	.uinfo = {
 		.aead = {
@@ -111,6 +116,7 @@ static struct xfrm_algo_desc aead_list[] = {
 },
 {
 	.name = "rfc4309(ccm(aes))",
+	.compat = "ccm",
 
 	.uinfo = {
 		.aead = {
@@ -201,6 +207,7 @@ static struct xfrm_algo_desc aalg_list[] = {
 },
 {
 	.name = "hmac(sha384)",
+	.compat = "sha384",
 
 	.uinfo = {
 		.auth = {
@@ -218,6 +225,7 @@ static struct xfrm_algo_desc aalg_list[] = {
 },
 {
 	.name = "hmac(sha512)",
+	.compat = "sha512",
 
 	.uinfo = {
 		.auth = {
@@ -253,6 +261,7 @@ static struct xfrm_algo_desc aalg_list[] = {
 },
 {
 	.name = "xcbc(aes)",
+	.compat = "aes-xcbc",
 
 	.uinfo = {
 		.auth = {
@@ -435,6 +444,7 @@ static struct xfrm_algo_desc ealg_list[] = {
 },
 {
 	.name = "rfc3686(ctr(aes))",
+	.compat = "aes-ctr",
 
 	.uinfo = {
 		.encr = {
-- 
1.6.4.1

