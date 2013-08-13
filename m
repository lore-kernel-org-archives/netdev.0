From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] SolutionEngine SH771x: remove Ether support
Date: Wed, 14 Aug 2013 01:32:21 +0400
Message-ID: <520AA5E5.5000803@cogentembedded.com>
References: <201308130217.03133.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: linux-sh@vger.kernel.org, lethal@linux-sh.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201308130217.03133.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/13/2013 02:17 AM, I wrote:

> The 'sh_eth' driver's probe will crash as the platform code is hopelessly behind
> the platform data -- it passes PHY ID instead of 'struct sh_eth_plat_data *'.
> Even if it's fixed, the driver probe will fail as the 'struct sh_eth_cpu_data'
> indicates presence of TSU but the platform device resource  for it is absent.
> Since I have no data to fix it, I think it's best to remove the erratic code.

    After looking at the original driver, it seems I've got the necessary 
data... but both Ether controllers seems to have shared TSU which is not yet 
supported by the driver (there was a patch from Iwamatsu-san to implement it 
but it hasn't been merged).

> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

WBR, Sergei

