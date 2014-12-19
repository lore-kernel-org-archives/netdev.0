From: Feng Kan <fkan@apm.com>
Subject: Re: [PATCH] net: eth: xgene: change APM X-Gene SoC platform ethernet
 to support ACPI
Date: Fri, 19 Dec 2014 09:36:13 -0800
Message-ID: <CAL85gmCOLrcTijpEhXx1x5UjHu0sgS5DdGYJxY4mwPFKCHpU-g@mail.gmail.com>
References: <1418945991-31494-1-git-send-email-fkan@apm.com>
	<20141219.123107.1080751255468272638.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, patches <patches@apm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141219.123107.1080751255468272638.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 19, 2014 at 9:31 AM, David Miller <davem@davemloft.net> wrote:
> From: Feng Kan <fkan@apm.com>
> Date: Thu, 18 Dec 2014 15:39:51 -0800
>
>> +#define NO_MAC_FOUND 0
>> +#define RES_ENET_CSR 0
>> +#define RES_RING_CSR 1
>> +#define RES_RING_CMD 2
Is there a issue with the RES defines, do you prefer enum types?

>
> Don't define your own magic set of error return semantics.
>
> For example, in the MAC address acquisition case, just verify that
> you get an ETH_ALEN length value from the fetch routines and return
> -ENODEV or similar if you do not.
Thanks, well change.
