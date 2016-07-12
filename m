From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 01/11] bpf: add XDP prog type for early driver filter
Date: Mon, 11 Jul 2016 23:02:54 -0700 (PDT)
Message-ID: <20160711.230254.53567533766522969.davem@davemloft.net>
References: <1468272598-21390-1-git-send-email-bblanco@plumgrid.com>
	<1468272598-21390-2-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	saeedm@dev.mellanox.co.il, kafai@fb.com, brouer@redhat.com,
	as754m@att.com, alexei.starovoitov@gmail.com, gerlitz.or@gmail.com,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	tgraf@suug.ch, tom@herbertland.com, daniel@iogearbox.net
To: bblanco@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbcGLGC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 02:02:56 -0400
In-Reply-To: <1468272598-21390-2-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brenden Blanco <bblanco@plumgrid.com>
Date: Mon, 11 Jul 2016 14:29:48 -0700

> +	WARN_ONCE(1, "\n"
> +		     "*****************************************************\n"
> +		     "**   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **\n"
> +		     "**                                               **\n"
> +		     "** XDP program returned unknown value %-10u **\n"
> +		     "**                                               **\n"
> +		     "** XDP programs must return a well-known return  **\n"
> +		     "** value. Invalid return values will result in   **\n"
> +		     "** packet loss.                                  **\n"
> +		     "**                                               **\n"
> +		     "**   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **\n"
> +		     "*****************************************************\n",

This is rediculous.

The log message should be concise, one line, and not scream things
like "NOTICE".  That's what the log level is for, to indicate the
severity of the issue.
