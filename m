From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: show stopped status in sysfs
Date: Mon, 03 May 2010 15:05:24 -0700 (PDT)
Message-ID: <20100503.150524.250828270.davem@davemloft.net>
References: <20100503212423.GA15998@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ebiederm@xmission.com,
	johannes@sipsolutions.net, therbert@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100503212423.GA15998@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 4 May 2010 00:24:25 +0300

> @@ -303,6 +313,7 @@ static struct device_attribute net_class_attributes[] = {
>  	__ATTR(address, S_IRUGO, show_address, NULL),
>  	__ATTR(broadcast, S_IRUGO, show_broadcast, NULL),
>  	__ATTR(carrier, S_IRUGO, show_carrier, NULL),
> +	__ATTR(carrier, S_IRUGO, show_stopped, NULL),

Besides the fact that you have to publish this as a per-queue attribute,
you're also erroneously naming it 'carrier' here.
