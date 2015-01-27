From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/2] sh_eth: massage PM code
Date: Tue, 27 Jan 2015 22:06:57 +0300
Message-ID: <54C7E1D1.9050707@cogentembedded.com>
References: <5608250.lrFkJTjgSf@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5608250.lrFkJTjgSf@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01/22/2015 01:16 AM, Sergei Shtylyov wrote:

>     Here's a set of 2 patches against DaveM's 'net-next.git' repo. We're adding
> the support for suspend/hibernation as well as somewhat changing the existing
> code. There are still MDIO-related issue with suspend (kernel exception), we've
> been working on it and shall address it with a separate patch...

    It turned out that Florian Fainelli's recent series was the best approach 
to fixing this issue. We were only looking at our driver while it was a common 
MDIO problem...

> [1/2] sh_eth: use SET_RUNTIME_PM_OPS()
> [2/2] sh_eth: add more PM methods

WBR, Sergei

