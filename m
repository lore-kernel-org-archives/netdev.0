From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH v2] net: mv643xx_eth: use managed devm_kzalloc
Date: Thu, 11 Apr 2013 08:53:19 +0200
Message-ID: <51665DDF.4060205@gmail.com>
References: <1365615483-26318-1-git-send-email-sebastian.hesselbarth@gmail.com> <1365626527-27233-1-git-send-email-sebastian.hesselbarth@gmail.com> <20130410.233933.2109788843089649198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, andrew@lunn.ch, jason@lakedaemon.net,
	florian@openwrt.org, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130410.233933.2109788843089649198.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/11/2013 05:39 AM, David Miller wrote:
> From: Sebastian Hesselbarth<sebastian.hesselbarth@gmail.com>
> Date: Wed, 10 Apr 2013 22:42:07 +0200
>
>> This patch moves shared private data kzalloc to managed devm_kzalloc and
>> cleans now unneccessary kfree and error handling.
>>
>> Signed-off-by: Sebastian Hesselbarth<sebastian.hesselbarth@gmail.com>
>
> This doesn't apply cleanly to the net-next tree.

Yeah. I sent two single patches for mv643xx_eth, while they should
have been sent together in one patch set. I'll prepare a cover letter
and resend both in one patch set.

Sebastian
