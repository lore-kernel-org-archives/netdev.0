From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] tc: print raw qdisc handle.
Date: Sun, 13 Nov 2016 09:53:37 +0300
Message-ID: <20161113095337.1ac19e42@samsung9>
References: <1478790392-13028-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:34821 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932150AbcKMGxn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 01:53:43 -0500
Received: by mail-lf0-f49.google.com with SMTP id b14so38335695lfg.2
        for <netdev@vger.kernel.org>; Sat, 12 Nov 2016 22:53:42 -0800 (PST)
In-Reply-To: <1478790392-13028-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Nov 2016 10:06:32 -0500
Roman Mashak <mrv@mojatatu.com> wrote:

> Resending patch after fixing indentation and spaces.
> 
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

iproute2 uses kernel coding style. This patch fails basic checkpatch.


WARNING: suspect code indent for conditional statements (8, 11)
#31: FILE: tc/tc_qdisc.c:241:
+	if (!show_raw) {
+	   fprintf(fp, "qdisc %s %x: ", rta_getattr_str(tb[TCA_KIND]),

total: 0 errors, 1 warnings, 15 lines checked
