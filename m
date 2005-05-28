From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: support restricting speed+duplex in autonegotiation
Date: Sat, 28 May 2005 16:42:07 +0200
Message-ID: <20050528144207.GA17021@electric-eye.fr.zoreil.com>
References: <4297A0F7.5070209@phekda.gotadsl.co.uk> <4297B479.1080404@candelatech.com> <429871F9.6040305@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, Linux netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
Content-Disposition: inline
In-Reply-To: <429871F9.6040305@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe <rich@phekda.gotadsl.co.uk> :
[...]
> This particular code is to support the "media" option for the r8169 
> module. The "media" option is marked as deprecated in favour of ethtool.

The current code is supposed to provide via ethtool the same function that
the media option did in Realtek's version of the driver (i.e. mostly a
current 'ethtool -s ethX autoneg off speed foo duplex bar').

Afaik, neither in Realtek's code nor in the current in-kernel driver does
the (obsolescent) "media" code do what one would expect from a "media"
option.

--
Ueimor
