From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH net-next v2 2/3] sh_eth: add support RMIIMODE register
Date: Thu, 06 Jun 2013 00:43:55 +0400
Message-ID: <51AFA30B.4080809@cogentembedded.com>
References: <1368499073-21975-1-git-send-email-horms+renesas@verge.net.au> <1368499073-21975-3-git-send-email-horms+renesas@verge.net.au> <519240C7.1060406@cogentembedded.com> <20130515005117.GC12246@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20130515005117.GC12246@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/15/2013 04:51 AM, Simon Horman wrote:

>>> This change is motivated by the lager board which uses the r8a7790 SoC,
>>> an R-Car SoC. For this board setting the RMIIMODE register is necessary.
>>> This patch assumes this is valid for all R-Car SoCs.
>>     No, RMIIMODE register is not documented on R8A7778/9 SoCs and
>> this location is described as reserved. How's it called in R8A7790
>> manual, CXR15?
> It appears to be undocumented in the R8A7790 I have.

     Of the manuals I have now this register is only documented in R-Car 
H2 user's manual 0.50,

> Empirically it seems necessary for the lager/R8A7790.

    The manual confirms that.

> To be honest I am entirely unsure of its relevance to other SoCs.
>
> I wonder if a better approach would be to add a flag to platform
> data rather than struct sh_eth_cpu_data. This would allow the register
> to only be accessed on boards where it is known to be useful.

    No, this doesn't depend on the board, judging on the H2 manual.
You just must write it to 1 on R-Car H2 in order for Ether to operate.

>
>>> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>>
WBR, Sergei


