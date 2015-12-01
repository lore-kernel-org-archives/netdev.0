From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 08/17] hv_netvsc: Don't ask for additional
 head room in the skb
Date: Tue, 01 Dec 2015 15:41:47 -0500 (EST)
Message-ID: <20151201.154147.1720863076099915966.davem@davemloft.net>
References: <1448742017-22693-1-git-send-email-kys@microsoft.com>
	<1448742045-22732-1-git-send-email-kys@microsoft.com>
	<1448742045-22732-8-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
	jasowang@redhat.com
To: kys@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448742045-22732-8-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Sat, 28 Nov 2015 12:20:36 -0800

> +#elseif defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25)

The correct CPP directive is "#elif".
