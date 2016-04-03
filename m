From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/6] net: ethernet: renesas: ravb_main: test clock rate to
 avoid division by 0
Date: Mon, 4 Apr 2016 01:28:44 +0300
Message-ID: <5701991C.4020904@cogentembedded.com>
References: <1456958018-7849-1-git-send-email-wsa@the-dreams.de>
 <1456958018-7849-3-git-send-email-wsa@the-dreams.de>
 <20160403213641.GA24129@katana>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-renesas-soc@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Wolfram Sang <wsa@the-dreams.de>, linux-kernel@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160403213641.GA24129@katana>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/04/2016 12:36 AM, Wolfram Sang wrote:

>> From: Wolfram Sang <wsa+renesas@sang-engineering.com>
>>
>> The clk API may return 0 on clk_get_rate, so we should check the result before
>> using it as a divisor.
>>
>> Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>
>
> Ping.

    http://patchwork.ozlabs.org/patch/591160/

    I have no idea why it's marked this way... Dave?

MBR, Sergei
