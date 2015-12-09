From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: arRe: [PATCH net-next 2/2] net: hns: enet specisies a reference to dsaf (config and documents)
Date: Wed, 09 Dec 2015 11:00:21 +0100
Message-ID: <4902591.DhWVhdI4KP@wuerfel>
References: <1449295856-31068-1-git-send-email-yankejian@huawei.com> <1503684.BNZUVaD74W@wuerfel> <5667F379.2010108@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "Yankejian (Hackim Yim)" <yankejian@huawei.com>,
	mark.rutland@arm.com, lisheng011@huawei.com,
	salil.mehta@huawei.com, liguozhu@huawei.com,
	haifeng.wei@huawei.com, pawel.moll@arm.com,
	ijc+devicetree@hellion.org.uk, catalin.marinas@arm.com,
	will.deacon@arm.com, linux-kernel@vger.kernel.org,
	xuwei5@hisilicon.com, devicetree@vger.kernel.org,
	robh+dt@kernel.org, huangdaode@hisilicon.com, galak@codeaurora.org,
	netdev@vger.kernel.org, fengguang.wu@intel.com,
	Yisen.Zhuang@huawei.com, davem@davemloft.net
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5667F379.2010108@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 09 December 2015 17:25:13 Yankejian wrote:
>  thanks a lot for pointing it out.
> 
>  It is great regret that this change breaks compatibility with old dtbs.
>  this is a new driver which is run on developing boards, and all the
>  clients' boards are developing boards. So we provide them a method to
>  update the firmware on the board, once we update the dtsi and kernel,
>  we require our clients to update the existed firmware and kernel.
>  Therefore, these changes is actually under control. Shall we treat this
>  by this way?

Ok, if you can show that the incompatible change is safe to do, that's
fine. Just put the explanation above into the patch description to
document that you have considered the effects of the change, and
to ensure that it gets done atomically.

Also, you have to merge the two patches into one to allow bisection,
or do a series of three patches that need to be applied in order:

1. add ae-handle property
2. change driver to use that property
3. remove ae-name property

	Arnd
