From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: [PATCH] r8169: support restricting speed+duplex in autonegotiation
Date: Sat, 28 May 2005 21:39:21 +0100
Message-ID: <4298D6F9.7030608@phekda.gotadsl.co.uk>
References: <4297A0F7.5070209@phekda.gotadsl.co.uk> <4297B479.1080404@candelatech.com> <429871F9.6040305@phekda.gotadsl.co.uk> <20050528144207.GA17021@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, Linux netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050528144207.GA17021@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Francois Romieu wrote:
> Richard Dawe <rich@phekda.gotadsl.co.uk> :
> [...]
> 
>>This particular code is to support the "media" option for the r8169 
>>module. The "media" option is marked as deprecated in favour of ethtool.
> 
> 
> The current code is supposed to provide via ethtool the same function that
> the media option did in Realtek's version of the driver (i.e. mostly a
> current 'ethtool -s ethX autoneg off speed foo duplex bar').

AFAICS the current r8169 driver always autonegotiates in xMII mode.

> Afaik, neither in Realtek's code nor in the current in-kernel driver does
> the (obsolescent) "media" code do what one would expect from a "media"
> option.

My patch doesn't change the behaviour of the "media" option.

Is the "media" part of the patch confusing?

Bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
