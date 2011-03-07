From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] ariadne: fix possible null dereference
Date: Sun, 06 Mar 2011 18:07:58 -0800 (PST)
Message-ID: <20110306.180758.226774711.davem@davemloft.net>
References: <20110306070832.GA26188@asset.uwaterloo.ca>
	<20110306111141.9cc51306.rdunlap@xenotime.net>
	<AANLkTiko+HzYMnGEtvb63Fzi2eNge6_iWPmk7EfjFma7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, j223yang@asset.uwaterloo.ca,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTiko+HzYMnGEtvb63Fzi2eNge6_iWPmk7EfjFma7@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sun, 6 Mar 2011 21:00:13 +0100

> On Sun, Mar 6, 2011 at 20:11, Randy Dunlap <rdunlap@xenotime.net> wrote:
>> On Sun, 6 Mar 2011 02:08:32 -0500 j223yang@asset.uwaterloo.ca wrote:
>>
>>> Hi Randy,
>>> I have tested my patch, and it is ok now.
>>> Could you please try patching again? Sorry for previous trouble.
>>> Thank you!
>>
>> Acked-by: Randy Dunlap <rdunlap@xenotime.net>
> 
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

People really don't actually read patches, I think.

Show me how dev can even be NULL here, it simply can't.

So the correct fix is to remove the dev==NULL check altogether.
