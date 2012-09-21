From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: mscan-mpc5xxx: fix return value check in mpc512x_can_get_clock()
Date: Fri, 21 Sep 2012 09:14:08 +0200
Message-ID: <505C13C0.8090200@grandegger.com>
References: <CAPgLHd9fRAvQ77rD_PCp45XW9-FsBisUATOT00Je39nbv5o28A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, grant.likely@secretlab.ca,
	rob.herring@calxeda.com, yongjun_wei@trendmicro.com.cn,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAPgLHd9fRAvQ77rD_PCp45XW9-FsBisUATOT00Je39nbv5o28A@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/21/2012 09:09 AM, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> In case of error, the function clk_get() returns ERR_PTR()
> and never returns NULL pointer. The NULL test in the error
> handling should be replaced with IS_ERR().
> 
> dpatch engine is used to auto generated this patch.
> (https://github.com/weiyj/dpatch)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Thanks,

Wolfgang.


