From: Bernie Harris <Bernie.Harris@alliedtelesis.co.nz>
Subject: Re: [PATCH v2] gre: Avoid kernel panic by clearing IPCB before
 dst_link_failure called
Date: Mon, 22 Feb 2016 04:57:05 +0000
Message-ID: <1456117025015.92803@alliedtelesis.co.nz>
References: <1454990874-10497-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
	<1455585016-7253-1-git-send-email-bernie.harris@alliedtelesis.co.nz>,<20160217.163152.1172947398779694144.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20160217.163152.1172947398779694144.davem@davemloft.net>
Content-Language: en-GB
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Again, I want to see this implemented in a way which causes things to be
> treated consistently across all tunneling types.
>
> Which means fixing the exact problem, IPCB(skb)->opt needing initilization.
>
> Thanks.

Thanks for the reply. I have revised my patch to apply to the range of tunnel types, and to only clear the opt field.