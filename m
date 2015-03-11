From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] fib_trie: call fib_table_flush_external under
 RTNL
Date: Wed, 11 Mar 2015 14:00:10 +0100
Message-ID: <20150311130010.GC2057@nanopsycho.orion>
References: <20150310183555.GB1743@kria>
 <1426017834-24209-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	alexander.h.duyck@redhat.com, sfeldma@gmail.com
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:40762 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbbCKNAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 09:00:14 -0400
Received: by wivr20 with SMTP id r20so38789668wiv.5
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 06:00:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426017834-24209-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 10, 2015 at 09:03:54PM CET, sd@queasysnail.net wrote:
>Move rtnl_lock() before the call to fib4_rules_exit so that
>fib_table_flush_external is called under RTNL.
>
>Fixes: 104616e74e0b ("switchdev: don't support custom ip rules, for now")
>Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>


Reviewed-by: Jiri Pirko <jiri@resnulli.us>
