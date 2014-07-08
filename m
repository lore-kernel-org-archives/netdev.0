From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Tue, 8 Jul 2014 09:28:54 -0700
Message-ID: <CAGVrzcbRDFhbaUFnXtPHm0v0gtMatX7knPoPKB7Q5KuxoNXeJw@mail.gmail.com>
References: <20140704113907.468a366a@canb.auug.org.au> <20140707.195330.1593299312055099195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Vince Bridgers <vbridgers2013@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140707.195330.1593299312055099195.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-07-07 19:53 GMT-07:00 David Miller <davem@davemloft.net>:
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

I'll take care of this, since I am also using phy_suspend/resume in
the systemport driver, and the kbuild test robot reported a linker
failure.
-- 
Florian
