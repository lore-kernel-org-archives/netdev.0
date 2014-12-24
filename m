From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v3] tc: Show classes in tree view
Date: Wed, 24 Dec 2014 12:42:56 -0800
Message-ID: <20141224124256.0ca7fe70@urahara>
References: <1419381976-23986-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:47885 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbaLXWS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 17:18:57 -0500
Received: by mail-pd0-f174.google.com with SMTP id fp1so10563704pdb.33
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 14:18:57 -0800 (PST)
In-Reply-To: <1419381976-23986-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Dec 2014 02:46:16 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Added new '-t[ree]' which shows classes dependency
> in the tree view. Meanwhile only generic stats info
> is supported.
> 



I don't get strict about checkpatch. But ran this patch through and there are some minor
things that would be good to fix.
  1. Split long lines like:
WARNING: line over 80 characters
#198: FILE: tc/tc_class.c:219:
+static void tree_cls_show(FILE *fp, char *buf, struct hlist_head *root_list, int level)

  2. Don't use variable name 'childs', makes sense to call it children instead??

  3. Don't use space before * as in:
ERROR: "foo * bar" should be "foo *bar"
#285: FILE: tc/tc_class.c:305:
+	struct rtattr * tb[TCA_MAX+1] = {};
