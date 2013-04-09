From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next] netrom: fix invalid use of sizeof in nr_recvmsg()
Date: Tue, 9 Apr 2013 05:09:05 +0200
Message-ID: <20130409030905.GA2527@order.stressinduktion.org>
References: <CAPgLHd-yEmt_BJ52uZNsCA_-w85VhnN_HbfjG1QLVvR5kp7Xvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: ralf@linux-mips.org, minipli@googlemail.com, davem@davemloft.net,
	yongjun_wei@trendmicro.com.cn, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPgLHd-yEmt_BJ52uZNsCA_-w85VhnN_HbfjG1QLVvR5kp7Xvw@mail.gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 09, 2013 at 10:07:19AM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> sizeof() when applied to a pointer typed expression gives the size of the
> pointer, not that of the pointed data.
> Introduced by commit 3ce5ef(netrom: fix info leak via msg_name in nr_recvmsg)

I think it would be a good idea to enable -Wsizeof-pointer-memaccess
(gcc 4.8 feature) by default. While enabled there were no additional
warnings when I tested it some weeks ago. I will look into  this.

