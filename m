From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211_hwsim: Register and bind to driver
Date: Mon, 08 Apr 2013 11:12:54 +0200
Message-ID: <1365412374.25475.2.camel@jlt4.sipsolutions.net>
References: <20130408090633.GB2818@piware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Dan Williams <dcbw@redhat.com>
To: Martin Pitt <martin.pitt@ubuntu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130408090633.GB2818@piware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks fine, but ...

> @@ -2179,6 +2183,8 @@ static int __init init_mac80211_hwsim(void)
>  	if (IS_ERR(hwsim_class))
>  		return PTR_ERR(hwsim_class);
>  
> +	driver_register(&mac80211_hwsim_driver);
> +
>  	memset(addr, 0, ETH_ALEN);
>  	addr[0] = 0x02;

I think you forgot to update the error path to unregister the driver.

johannes
