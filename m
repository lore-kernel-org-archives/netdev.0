From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/3] ifstat: Add extended statistics to ifstat
Date: Thu, 1 Dec 2016 10:46:11 -0800
Message-ID: <20161201104611.1e3a5b05@xeon-e3>
References: <1479996760-61271-1-git-send-email-nogahf@mellanox.com>
        <1479996760-61271-3-git-send-email-nogahf@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eladr@mellanox.com, yotamg@mellanox.com,
        jiri@mellanox.com, idosch@mellanox.com, ogerlitz@mellanox.com
To: Nogah Frankel <nogahf@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34213 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932248AbcLASqO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 13:46:14 -0500
Received: by mail-pf0-f179.google.com with SMTP id c4so47483133pfb.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 10:46:14 -0800 (PST)
In-Reply-To: <1479996760-61271-3-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Nov 2016 16:12:39 +0200
Nogah Frankel <nogahf@mellanox.com> wrote:

> Add extended stats option for ifstat. It supports stats that are in the
> nesting level as the "normal" stats or one lower, as long as they are in
> the same struct type as the "normal" stats.
> Every extension is unaware of data from other extension and is being
> presented by itself.
> The extension can be called by its name or any shorten of it. If there is
> more then one matched, the first one will be picked.
> 
> To get the extended stats the flag -x <stats type> is used.
> 
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>

Finally clearing up iproute2 patch backlog. This feature looks good,
but does not apply cleanly to current git master branch.

--- misc/ifstat.c
+++ misc/ifstat.c
@@ -733,7 +790,8 @@ static void usage(void)
 "   -s, --noupdate	don\'t update history\n"
 "   -t, --interval=SECS	report average over the last SECS\n"
 "   -V, --version	output version information\n"
-"   -z, --zeros		show entries with zero activity\n");
+"   -z, --zeros		show entries with zero activity\n"
+"   -x, --extended=TYPE	show extended stats of TYPE\n");
 
 	exit(-1);
 }

Please rebase your patches and resubmit.
