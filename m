From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v12 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 28 Jun 2016 05:33:50 -0400 (EDT)
Message-ID: <20160628.053350.1891488485477523405.davem@davemloft.net>
References: <BLUPR03MB1410A0ECB526A1CD13814D36BF2E0@BLUPR03MB1410.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com,
	vkuznets@redhat.com, cavery@redhat.com, kys@microsoft.com,
	haiyangz@microsoft.com, joe@perches.com
To: decui@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BLUPR03MB1410A0ECB526A1CD13814D36BF2E0@BLUPR03MB1410.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Fri, 24 Jun 2016 07:45:24 +0000

> +	while ((ret = vmalloc(size)) == NULL)
> +		ssleep(1);

This is completely, and entirely, unacceptable.

If the allocation fails, you return an error and release
your resources.

You don't just loop forever waiting for it to succeed.
