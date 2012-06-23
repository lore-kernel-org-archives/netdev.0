From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_eth: fix the rxdesc pointer when rx descriptor
 empty happens
Date: Fri, 22 Jun 2012 21:51:02 -0700 (PDT)
Message-ID: <20120622.215102.2154734910994772908.davem@davemloft.net>
References: <Pine.LNX.4.64.1206201507260.20254@axis700.grange>
	<4FE2784A.70208@renesas.com>
	<Pine.LNX.4.64.1206221610350.17552@axis700.grange>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshihiro.shimoda.uh@renesas.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: g.liakhovetski@gmx.de
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1206221610350.17552@axis700.grange>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Date: Fri, 22 Jun 2012 16:16:38 +0200 (CEST)

> Hi Shimoda-san
> 
> On Thu, 21 Jun 2012, Shimoda, Yoshihiro wrote:
> 
>> Hello Guennadi-san,
>> 
>> 2012/06/20 22:10, Guennadi Liakhovetski wrote:
>> > Hello Shimoda-san
>> > 
>> > On Tue, 29 May 2012, Shimoda, Yoshihiro wrote:
>> > 
>> >> When Receive Descriptor Empty happens, rxdesc pointer of the driver
>> >> and actual next descriptor of the controller may be mismatch.
>> >> This patch fixes it.
>> > 
>> > Unfortunately, this patch breaks networking on ecovec (sh7724). Booting 
>> > with dhcp and NFS-root progresses very slowly with lots of "nfs: server 
>> > not responding / Ok" messages and never completes. Reverting it in current 
>> > Linus' tree fixes the problem.
>> 
>> Thank you very much for the report.
>> The SH7724 doesn't set the RMCR register. So, the EDRRR will be clear after
>> the controller receives a freme every time.
>> So, the "fix the rxdesc pointer" had to check a condition.
>> 
>> I wrote a patch for the issue as the following.
>> If possible, would you try the patch?
> 
> Yes, it does seem to fix the problem.
> 
> Tested-by: Guennadi Liakhovetski <g.liakhovetski@gmx.de>

Applied, thanks.
