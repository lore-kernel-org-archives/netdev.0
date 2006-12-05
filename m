From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/7] Sync with 2.6.19 kernel header about include/linux.
Date: Tue, 5 Dec 2006 12:54:15 +0100
Message-ID: <20061205115415.GY8693@postel.suug.ch>
References: <11653137213434-git-send-email-nakam@linux-ipv6.org> <20061205104211.GW8693@postel.suug.ch> <45755BB5.2060707@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:42609 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937524AbWLELxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 06:53:54 -0500
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <45755BB5.2060707@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Masahide NAKAMURA <nakam@linux-ipv6.org> 2006-12-05 20:44
> Thomas Graf wrote:
> >* Masahide NAKAMURA <nakam@linux-ipv6.org> 2006-12-05 19:15
> >>diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
> >>index 8270aac..4418c8d 100644
> >>--- a/include/linux/fib_rules.h
> >>+++ b/include/linux/fib_rules.h
> >>@@ -6,7 +6,6 @@ #include <linux/rtnetlink.h>
> >> 
> >> /* rule is permanent, and cannot be deleted */
> >> #define FIB_RULE_PERMANENT	1
> >>-#define FIB_RULE_INVERT		2
> >>
> >> struct fib_rule_hdr
> >> {
> >>@@ -35,7 +34,7 @@ enum
> >> 	FRA_UNUSED3,
> >> 	FRA_UNUSED4,
> >> 	FRA_UNUSED5,
> >>-	FRA_FWMARK,	/* mark */
> >>+	FRA_FWMARK,	/* netfilter mark */
> >> 	FRA_FLOW,	/* flow/class id */
> >> 	FRA_UNUSED6,
> >> 	FRA_UNUSED7,
> >
> >Why are you reverting this?
> 
> I just update the header about include/linux without thinking.
> Should I have to update them except fib_rules.h?

The iproute2 git tree already contains patches for the
2.6.20 release.
