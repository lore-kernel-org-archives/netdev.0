From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 0/7] net: dsa: mv88e6xxx: support switchdev
 FDB objects
Date: Tue, 11 Aug 2015 14:18:42 -0400 (EDT)
Message-ID: <1084602462.1280363.1439317122548.JavaMail.zimbra@savoirfairelinux.com>
References: <1065657734.1253359.1439310306115.JavaMail.zimbra@savoirfairelinux.com> <20150811.103817.787813230853567028.davem@davemloft.net> <55CA38F7.4010105@gmail.com> <20150811.110708.2068514265578197752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	Guenter Roeck <linux@roeck-us.net>, andrew@lunn.ch,
	sfeldma@gmail.com, jiri@resnulli.us
To: David <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150811.110708.2068514265578197752.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Aug 11, 2015, at 2:07 PM, David davem@davemloft.net wrote:

> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Tue, 11 Aug 2015 11:03:35 -0700
> 
>> Put differently, my question is how do you value not rewriting
>> history vs. breaking bisectability (by accident of course)?
> 
> I never will rewrite history, ever.
> 
> Too many people clone my tree and depend upon it.

Sorry, I still don't understand. What are the consequences of:

    git revert -m 1 f1d5ca4

Then applying v3?

You already did that in the past:
https://github.com/torvalds/linux/commit/1f2cd84

Thanks,
-v
