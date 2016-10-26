From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/2] tc filters: fix filters to display handle
 when deleted even when no option
Date: Wed, 26 Oct 2016 10:57:49 -0700
Message-ID: <20161026105749.1e366ef7@xeon-e3>
References: <1476696885-22214-1-git-send-email-jhs@emojatatu.com>
        <1476696885-22214-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, mrv@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36437 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752263AbcJZR5e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 13:57:34 -0400
Received: by mail-pf0-f173.google.com with SMTP id e6so790223pfk.3
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 10:57:34 -0700 (PDT)
In-Reply-To: <1476696885-22214-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Oct 2016 05:34:45 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Fix a few stylistic things that hurt my eyes while at it.
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

This patch has whitespace issues, please fix and resubmit.


ARNING: suspect code indent for conditional statements (16, 19)
#127: FILE: tc/f_fw.c:126:
+		if (tb[TCA_FW_MASK]) {
+		   __u32 tmask = rta_getattr_u32(tb[TCA_FW_MASK]);

WARNING: Statements should start on a tabstop
#131: FILE: tc/f_fw.c:129:
+		   if (tmask != 0xFFFFFFFF)

WARNING: suspect code indent for conditional statements (19, 27)
#131: FILE: tc/f_fw.c:129:
+		   if (tmask != 0xFFFFFFFF)
+			   mask = tmask;
