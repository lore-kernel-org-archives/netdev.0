From: Thomas Chou <thomas@wytron.com.tw>
Subject: Re: [Nios2-dev] [PATCH] ethoc: fix null dereference in ethoc_probe
Date: Tue, 25 May 2010 14:51:36 +0800
Message-ID: <4BFB7378.6070900@wytron.com.tw>
References: <20100522155455.GE22515@bicker>	<1274669042-1901-1-git-send-email-thomas@wytron.com.tw> <4BFB6B4B.3020107@zhaw.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thierry.reding@avionic-design.de,
	linux-kernel@vger.kernel.org, Dan Carpenter <error27@gmail.com>
To: nios2-dev@sopc.et.ntust.edu.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BFB6B4B.3020107@zhaw.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tobias Klauser wrote:
>> @@ -944,6 +946,7 @@ static int ethoc_probe(struct platform_device *pdev)
>>  	priv = netdev_priv(netdev);
>>  	priv->netdev = netdev;
>>  	priv->dma_alloc = 0;
>> +	priv->io_region_size = mmio->end - mmio->start + 1;
> 
> Better use the resource_size inline here.

Hi Tobias,

I just see your patch of resource_size from the git log. Sorry, I missed 
this one. I will send update on this. Thank you.

Cheers,
Thomas
