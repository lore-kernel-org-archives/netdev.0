From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 07/10] ss: renaming and export of current_filter
Date: Wed, 19 Aug 2015 16:18:00 -0700
Message-ID: <20150819161800.6e7c1ab7@uryu.home.lan>
References: <1439232744-19505-1-git-send-email-matthias.tafelmeier@gmx.net>
	<1439232744-19505-8-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36750 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062AbbHSXSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 19:18:03 -0400
Received: by pawq9 with SMTP id q9so13064499paw.3
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 16:18:02 -0700 (PDT)
In-Reply-To: <1439232744-19505-8-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The series looks good, but this patch does not apply to current master branch.

The rejected part was.

--- misc/ss.c
+++ misc/ss.c
@@ -3273,7 +3273,7 @@ int main(int argc, char *argv[])
 		{
 			char *p, *p1;
 			if (!saw_query) {
-				current_filter.dbs = 0;
+				ss_current_filter.dbs = 0;
 				saw_query = 1;
 				do_default = 0;
 			}

Please resubmit whole patch series, thanks.
