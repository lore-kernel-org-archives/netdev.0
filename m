From: Bryan Wu <bryan.wu@canonical.com>
Subject: Re: [PATCH] netdev/fec.c: add phylib supporting to enable carrier
	detection
Date: Wed, 31 Mar 2010 20:11:50 +0800
Message-ID: <4BB33C06.1040307@canonical.com>
References: <1269597052-10104-1-git-send-email-bryan.wu@canonical.com>
	<20100331075746.GO2241@pengutronix.de>
	<20100331081004.GB23391@pengutronix.de>
Reply-To: bryan.wu@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@lists.ubuntu.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org
To: Wolfram Sang <w.sang@pengutronix.de>,
	Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <kernel-team-bounces@lists.ubuntu.com>
In-Reply-To: <20100331081004.GB23391@pengutronix.de>
List-Unsubscribe: <https://lists.ubuntu.com/mailman/listinfo/kernel-team>,
	<mailto:kernel-team-request@lists.ubuntu.com?subject=unsubscribe>
List-Archive: <https://lists.ubuntu.com/archives/kernel-team>
List-Post: <mailto:kernel-team@lists.ubuntu.com>
List-Help: <mailto:kernel-team-request@lists.ubuntu.com?subject=help>
List-Subscribe: <https://lists.ubuntu.com/mailman/listinfo/kernel-team>,
	<mailto:kernel-team-request@lists.ubuntu.com?subject=subscribe>
Sender: kernel-team-bounces@lists.ubuntu.com
Errors-To: kernel-team-bounces@lists.ubuntu.com
List-Id: netdev.vger.kernel.org

On 03/31/2010 04:10 PM, Wolfram Sang wrote:
>> With rounding this would be:
>>
>> (clk_get_rate() + 4999999) / 5000000
>
> Better use DIV_ROUND_UP(clk_get_rate(), 5000000)?
>
> Regards,
>
>     Wolfram
>

Sascha and Wolfram,

Thanks a lot. I updated the patch to v2 and sent it already.

-- 
Bryan Wu <bryan.wu@canonical.com>
Kernel Developer    +86.138-1617-6545 Mobile
Ubuntu Kernel Team | Hardware Enablement Team
Canonical Ltd.      www.canonical.com
Ubuntu - Linux for human beings | www.ubuntu.com
