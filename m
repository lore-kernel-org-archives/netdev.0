From: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Subject: Re: [patch] caif: add a sanity check to the tty name
Date: Tue, 03 Sep 2013 12:47:36 +0200
Message-ID: <5225BE48.2080302@lockless.no>
References: <20130903090232.GA4351@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130903090232.GA4351@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dan,

Agree, thank you!

With best regards,
Dmitry

Den 03. sep. 2013 11:02, skrev Dan Carpenter:
> -	sprintf(name, "cf%s", tty->name);
> +	result = snprintf(name, sizeof(name), "cf%s", tty->name);
> +	if (result >= IFNAMSIZ)
> +		return -EINVAL;

