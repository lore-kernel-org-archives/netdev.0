From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Wed, 15 Oct 2014 21:15:12 -0700
Message-ID: <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
	 <20141015.002514.384962932982389732.davem@davemloft.net>
	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>
	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-10-16 at 02:17 +0000, Jiafei.Pan@freescale.com wrote:

> Thanks for your comments and suggestion. In my case, I want to build skb
> from hardware block specified memory, I only can see two ways, one is modified
> net card driver replace common skb allocation function with my specially
> functions, another way is to hack common skb allocation function in which
> redirect to my specially functions. My patch is just for the second way.
> Except these two ways, would you please give me some advice for some other
> ways for my case? Thanks

I suggest you read drivers/net/ethernet numerous examples.

No need to change anything  in net/* or include/*, really.

For a start, look at drivers/net/ethernet/intel/igb/igb_main.c

Mentioning 'hack' in your mails simply should hint you are doing
something very wrong.

What makes you think your hardware is so special ?


