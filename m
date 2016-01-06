From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethernet/atheros/alx: sanitize buffer sizing
 and padding
Date: Wed, 06 Jan 2016 01:23:26 -0500 (EST)
Message-ID: <20160106.012326.1058946039396006074.davem@davemloft.net>
References: <1452035554-26145-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, eugene.shatokhin@rosalab.ru,
	prudy1@o2.pl, jcliburn@gmail.com, chris.snook@gmail.com,
	netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452035554-26145-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Tue,  5 Jan 2016 18:12:34 -0500

> -	if ((raw_mtu + 8) < ALX_TXQ1_JUMBO_TSO_TH)
> -		val = (raw_mtu + 8 + 7) >> 3;
> +	if ((raw_mtu) < ALX_TXQ1_JUMBO_TSO_TH)
> +		val = (raw_mtu + 7) >> 3;

The parenthesis around 'raw_mtu' is superfluous, please
remove it.

Otherwise this looks great, please resubmit with that fixed
up.

Thanks.
