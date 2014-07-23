From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Wed, 23 Jul 2014 13:38:01 -0500
Message-ID: <CAOwfj2PsBhW3j4Tm4UMc1iCf=-xX8bhKcNLuo+iMzQw=jZog+A@mail.gmail.com>
References: <20140704113907.468a366a@canb.auug.org.au>
	<20140707.195330.1593299312055099195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: sfr@canb.auug.org.au,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140707.195330.1593299312055099195.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

On Mon, Jul 7, 2014 at 9:53 PM, David Miller <davem@davemloft.net> wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 4 Jul 2014 11:39:07 +1000
>
>> After merging the net tree, today's linux-next build (x86_64
>> allmodconfig) failed like this:
>>
>> ERROR: "phy_resume" [drivers/net/ethernet/stmicro/stmmac/stmmac.ko] undefined!
>>
>> Caused by commit 0acf16768740 ("net: stmmac: add platform init/exit for
>> Altera's ARM socfpga").
>>
>> I reverted that commit for today.
>
> Vince you haven't made any effort to fix this build failure, so I am reverting
> your changes.

My apologies, I was out on vacation and I should have checked for this
before submitting. I have a corrected patch that I'm ready to submit.

Vince
