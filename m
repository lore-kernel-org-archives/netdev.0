From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Wed, 23 Jul 2014 13:42:55 -0500
Message-ID: <CAOwfj2O8wZWcWsjvTFX+uXEqS9pA5z4vh9szPfGcuQSYcoCgew@mail.gmail.com>
References: <20140704113907.468a366a@canb.auug.org.au>
	<20140707.195330.1593299312055099195.davem@davemloft.net>
	<CAOwfj2PsBhW3j4Tm4UMc1iCf=-xX8bhKcNLuo+iMzQw=jZog+A@mail.gmail.com>
	<CAGVrzcZWGQiSjBs0iKofLvnk7wFth2VkZ02ycaic855O5EzxFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-next <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcZWGQiSjBs0iKofLvnk7wFth2VkZ02ycaic855O5EzxFw@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2014 at 1:40 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> 2014-07-23 11:38 GMT-07:00 Vince Bridgers <vbridgers2013@gmail.com>:
>> Hi all,
>>
>> On Mon, Jul 7, 2014 at 9:53 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Stephen Rothwell <sfr@canb.auug.org.au>
>>> Date: Fri, 4 Jul 2014 11:39:07 +1000
>>>
>>>> After merging the net tree, today's linux-next build (x86_64
>>>> allmodconfig) failed like this:
>>>>
>>>> ERROR: "phy_resume" [drivers/net/ethernet/stmicro/stmmac/stmmac.ko] undefined!
>>>>
>>>> Caused by commit 0acf16768740 ("net: stmmac: add platform init/exit for
>>>> Altera's ARM socfpga").
>>>>
>>>> I reverted that commit for today.
>>>
>>> Vince you haven't made any effort to fix this build failure, so I am reverting
>>> your changes.
>>
>> My apologies, I was out on vacation and I should have checked for this
>> before submitting. I have a corrected patch that I'm ready to submit.
>
> net-next does contain a change that adds EXPORT_SYMBOLE() to
> phy_resume and phy_suspend, you might be able to get along with just
> re-submitting your patches if they still apply cleanly?
> --
> Florian

Ok, I was just parsing the other email thread. I'll try that.

Cheers

Vince
