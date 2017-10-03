From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fib_rules: Fix fib_rules_ops->compare
 implementations to support exact match
Date: Tue, 03 Oct 2017 14:54:18 -0700 (PDT)
Message-ID: <20171003.145418.677435703318514230.davem@davemloft.net>
References: <20170930085909.1103-1-shmulik@nsof.io>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mateusz.bajorski@nokia.com,
        dsa@cumulusnetworks.com, tgraf@suug.ch, shmulik.ladkani@gmail.com
To: shmulik@nsof.io
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751247AbdJCVyU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 17:54:20 -0400
In-Reply-To: <20170930085909.1103-1-shmulik@nsof.io>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik@nsof.io>
Date: Sat, 30 Sep 2017 11:59:09 +0300

> This leads to inconsistencies, depending on order of operations, e.g.:

I don't see any inconsistency.  When you insert using NLM_F_EXCL the
insertion fails if any existing rule matches or overlaps in any way
with the keys in the new rule.

Sorry I'm not going to apply this.
