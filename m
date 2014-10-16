From: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>
Subject: RE: [PATCH] net: use hardware buffer pool to allocate skb
Date: Thu, 16 Oct 2014 02:30:05 +0000
Message-ID: <43e8b86d47784ff78df70fc1b6e4b965@BLUPR03MB517.namprd03.prod.outlook.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
 <20141015113323.5321b2f7@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20141015113323.5321b2f7@uryu.home.lan>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Wednesday, October 15, 2014 5:33 PM
> To: Pan Jiafei-B37022
> Cc: davem@davemloft.net; jkosina@suse.cz; netdev@vger.kernel.org; Li Yang-Leo-
> R58472; linux-doc@vger.kernel.org
> Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
> 
> Since an skb can sit forever in an application queue, you have created
> an easy way to livelock the system when enough skb's are waiting to be
> read.

I think there is no possible to livelock the system, because in my patch
The function __netdev_alloc_skb will try to allocate hardware block buffer
Firstly if dev->alloc_hw_skb is set, but it will continue allocate normal
skb buffer if the hardware block buffer allocation fails.
