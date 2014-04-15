From: "Li, ZhenHua" <zhen-hual@hp.com>
Subject: Re: [PATCH 1/1] driver/net: remove unused code in cosa module
Date: Tue, 15 Apr 2014 09:44:31 +0800
Message-ID: <534C8EFF.1030804@hp.com>
References: <1397470116-19669-1-git-send-email-zhen-hual@hp.com> <20140414.133100.2108506432746999980.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kas@fi.muni.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140414.133100.2108506432746999980.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for your correction. I will send again with proper reason.

On 04/15/2014 01:31 AM, David Miller wrote:
> From: "Li, Zhen-Hua" <zhen-hual@hp.com>
> Date: Mon, 14 Apr 2014 18:08:36 +0800
>
>> For the cosa module, CONFIG_COSA can only be checked as 'm',
>> and cosa module can only be compiled as a module.
> That's not true, it's "tristate" in drivers/net/wan/Kconfig so it
> could be set to 'y' too.
>
> But there is another reason to make this change, because for such
> large timeout values only msleep() makes sense, udelay() could
> overflow it's internal precision.
>
> Please resubmit this with the proper reasoning and commit message.
