From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/ethernet/dec/tulip/uli526x.c: fix
 misleading indentation in uli526x_timer
Date: Wed, 03 Jun 2015 19:44:18 -0700 (PDT)
Message-ID: <20150603.194418.1009623373928255414.davem@davemloft.net>
References: <1433273477-52330-1-git-send-email-dmalcolm@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org
To: dmalcolm@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbbFDCoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 22:44:19 -0400
In-Reply-To: <1433273477-52330-1-git-send-email-dmalcolm@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Malcolm <dmalcolm@redhat.com>
Date: Tue,  2 Jun 2015 15:31:17 -0400

> This code in drivers/net/ethernet/dec/tulip/uli526x.c
> function "uli526x_timer":
> 
>   1086          } else
>   1087                  if ((tmp_cr12 & 0x3) && db->link_failed) {
>   [...snip...]
>   1109                  }
>   1110                  else if(!(tmp_cr12 & 0x3) && db->link_failed)
>   1111                  {
>   [...snip...]
>   1117                  }
>   1118                  db->init=0;
> 
> is misleadingly indented: the
>   db->init=0
> is indented as if part of the else clause at line 1086, but it is
> independent of it (no braces before the "if" at line 1087).
> 
> This patch fixes the indentation to reflect the actual meaning of the code,
> though is it actually meant to be part of the "else" clause?  (I'm a
> compiler developer, not a kernel person).  It also adds spaces around
> the assignment, to placate checkpatch.pl.

I think the code is arranged as intended and the indentation is just wrong.

Patch applied, thanks.
