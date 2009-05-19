From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] cleanup: remove unused parameter from
 fill method in fib_rules_ops.
Date: Tue, 19 May 2009 15:18:57 -0700 (PDT)
Message-ID: <20090519.151857.56095864.davem@davemloft.net>
References: <eb3ff54b0905190554i6293ebdfw6b06d54f1cd82f5b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42709
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752811AbZESWS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:18:59 -0400
In-Reply-To: <eb3ff54b0905190554i6293ebdfw6b06d54f1cd82f5b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Tue, 19 May 2009 15:54:26 +0300

> @@ -192,7 +192,7 @@ unsigned dnet_addr_type(__le16 addr)
>  }
>  
>  static int dn_fib_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
> -			    struct nlmsghdr *nlh, struct fib_rule_hdr *frh)
> +			    								  struct fib_rule_hdr *frh)
>  {

Please fix up this crazy multi-line tabbing that happened in
these function arg list transformations.

There's also space-tab sequences in here which should be fixed
up too in fact that's how I noticed the multi-line problem:

+ git apply --check --whitespace=error-all diff
diff:35: space before tab in indent.
			    								  struct fib_rule_hdr *frh)
diff:48: space before tab in indent.
			  									struct fib_rule_hdr *frh)
diff:61: space before tab in indent.
			  									struct fib_rule_hdr *frh)
fatal: 3 lines add whitespace errors.


Thanks.
