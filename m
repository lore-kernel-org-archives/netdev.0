From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/5] qeth: add layer 2 RX/TX checksum
 offloading
Date: Thu, 17 Sep 2015 16:24:07 -0700 (PDT)
Message-ID: <20150917.162407.2057471103024148470.davem@davemloft.net>
References: <1442313138-64526-1-git-send-email-ubraun@linux.vnet.ibm.com>
	<1442313138-64526-5-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, tmricht@linux.vnet.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbbIQXYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 19:24:08 -0400
In-Reply-To: <1442313138-64526-5-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Tue, 15 Sep 2015 12:32:17 +0200

> +int qeth_send_setassparms(struct qeth_card *, struct qeth_cmd_buffer *, __u16,
> +	long,
> +	int (*reply_cb)(struct qeth_card *, struct qeth_reply *, unsigned long),
> +	void *);

Function declarations and definitions that span multiple lines must begin
the second and subsequent lines precisely at the column right after the
openning parenthesis of the declaration/definition.

Indenting those lines just by a plain TAB character is not correct.

> +static int qeth_setassparms_cb(struct qeth_card *card,
> +			struct qeth_reply *reply, unsigned long data)

Likewise.

> +static struct qeth_cmd_buffer *qeth_get_setassparms_cmd(
> +	struct qeth_card *card, enum qeth_ipa_funcs ipa_func, __u16 cmd_code,
> +	__u16 len, enum qeth_prot_versions prot)

Likewise.

> +int qeth_send_setassparms(struct qeth_card *card,
> +	struct qeth_cmd_buffer *iob, __u16 len, long data,
> +	int (*reply_cb)(struct qeth_card *, struct qeth_reply *,
> +		unsigned long),
> +	void *reply_param)

Likewise.

And so on and so forth.
