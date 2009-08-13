From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/3] net: skb ftracer - Add config option to enable new
	ftracer (v3)
Date: Thu, 13 Aug 2009 11:20:45 -0400
Message-ID: <20090813152045.GB16682@hmsreliant.think-freely.org>
References: <20090807202130.GA26677@hmsreliant.think-freely.org> <20090813145917.GA16521@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, rostedt@goodmis.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50562 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbZHMPUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 11:20:46 -0400
Content-Disposition: inline
In-Reply-To: <20090813145917.GA16521@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb allocation / consumption corelator - Add config option

This patch adds a Kconfig option to enable the addtition of the skb source
tracer.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 Kconfig |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index 019f380..dcb263d 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -234,6 +234,16 @@ config BOOT_TRACER
 	  You must pass in initcall_debug and ftrace=initcall to the kernel
 	  command line to enable this on bootup.
 
+config SKB_SOURCES_TRACER
+	bool "Trace skb source information
+	select GENERIC_TRACER
+	help
+	   This tracer helps developers/sysadmins correlate skb allocation and
+	   consumption.  The idea being that some processes will primarily consume data
+	   that was allocated on certain numa nodes.  By being able to visualize which
+	   nodes the data was allocated on, a sysadmin or developer can optimize the
+	   scheduling of those processes to cut back on cross node chatter.
+
 config TRACE_BRANCH_PROFILING
 	bool
 	select GENERIC_TRACER
