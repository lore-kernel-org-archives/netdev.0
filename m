From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] gianfar: disable vlan tag insertion by default on 2.6.x
Date: Wed, 15 Oct 2014 12:09:49 +0200
Message-ID: <20141015100949.GA30089@1wt.eu>
References: <1413367234-28652-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sandeep.kumar@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Yue.Tao@windriver.com,
	guang.yang@windriver.com, joe@perches.com, festevam@gmail.com,
	richardcochran@gmail.com, clarocq@gmail.com,
	yongjun_wei@trendmicro.com.cn, claudiu.manoil@freescale.com,
	roy.xu@huawei.com, sky.wangfeng@huawei.com,
	Zhu Yanjun <Yanjun.Zhu@windriver.com>
To: Zhu Yanjun <zyjzyj2000@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1413367234-28652-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Zhu,

On Wed, Oct 15, 2014 at 06:00:33PM +0800, Zhu Yanjun wrote:
> In commit f43c75d4b6[gianfar: disable TX vlan based on kernel 2.6.x],
> gianfar nic disables TX vlan. But gianfar nic enables vlan tag 
> insertion by default. This will lead to unusable connections on 
> some configurations. Since vlan tag insertion is disabled by default 
> and it is not enabled any longer, it is not necessary to disable it again.
> 
> Zhu Yanjun (1):
>   gianfar: disable vlan tag insertion by default
> 
>  drivers/net/gianfar.c | 6 ------
>  1 file changed, 6 deletions(-)
> 
> -- 
> 1.9.1

There's no patch in this e-mail. Since you sent another e-mail with almost
the same subject, I'm confused, it's unclear to me whether I only need to
apply the patch in the other one with this commit message or if it's just
that you accidently dropped the patch when sending this e-mail. Could you
please enlighten me ?

Thanks,
Willy
