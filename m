From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: appletalk bugs
Date: Mon, 22 Oct 2007 12:55:36 -0600
Message-ID: <m18x5vasif.fsf@ebiederm.dsl.xmission.com>
References: <471CB159.1070706@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Gabriel C <nix.or.die@googlemail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:57339 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbXJVS4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 14:56:35 -0400
In-Reply-To: <471CB159.1070706@googlemail.com> (Gabriel C.'s message of "Mon,
	22 Oct 2007 16:19:05 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gabriel C <nix.or.die@googlemail.com> writes:

> Hi,
>
> modprobing appletalk on current git gives a warning in dmesg :
>
> [38506.600269] sysctl table check failed: /net/appletalk .3.7 procname does not
> match binary path procname

Oops.  My apologies it appears I made a mistake when creating my
table to check up on sysctl values.

This should fix it.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

---

diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index 3c9ef5a..ed6fe51 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -731,7 +731,7 @@ static struct trans_ctl_table trans_net_table[] = {
 	{ NET_UNIX,		"unix",		trans_net_unix_table },
 	{ NET_IPV4,		"ipv4",		trans_net_ipv4_table },
 	{ NET_IPX,		"ipx",		trans_net_ipx_table },
-	{ NET_ATALK,		"atalk",	trans_net_atalk_table },
+	{ NET_ATALK,		"appletalk",	trans_net_atalk_table },
 	{ NET_NETROM,		"netrom",	trans_net_netrom_table },
 	{ NET_AX25,		"ax25",		trans_net_ax25_table },
 	{ NET_BRIDGE,		"bridge",	trans_net_bridge_table },
