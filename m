From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH net-next v2 2/3] sh_eth: add support RMIIMODE register
Date: Wed, 15 May 2013 18:45:42 +0400
Message-ID: <51939F96.4090307@cogentembedded.com>
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

On 15-05-2013 4:51, Simon Horman wrote:

>>> This change is motivated by the lager board which uses the r8a7790 SoC,
>>> an R-Car SoC. For this board setting the RMIIMODE register is necessary.

>>> This patch assumes this is valid for all R-Car SoCs.

>>     No, RMIIMODE register is not documented on R8A7778/9 SoCs and
>> this location is described as reserved. How's it called in R8A7790
>> manual, CXR15?

> It appears to be undocumented in the R8A7790 I have.
> Empirically it seems necessary for the lager/R8A7790.

    I wonder where you got the info then (and what writing 1 to this 
register means)...

> To be honest I am entirely unsure of its relevance to other SoCs.

> I wonder if a better approach would be to add a flag to platform
> data rather than struct sh_eth_cpu_data. This would allow the register
> to only be accessed on boards where it is known to be useful.

    Maybe...

>>> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

WBR, Sergei

