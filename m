From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: support restricting speed+duplex in autonegotiation
Date: Mon, 30 May 2005 00:54:33 +0200
Message-ID: <20050529225433.GA24990@electric-eye.fr.zoreil.com>
References: <4297A0F7.5070209@phekda.gotadsl.co.uk> <4297B479.1080404@candelatech.com> <429871F9.6040305@phekda.gotadsl.co.uk> <20050528144207.GA17021@electric-eye.fr.zoreil.com> <4298D6F9.7030608@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, Linux netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
Content-Disposition: inline
In-Reply-To: <4298D6F9.7030608@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe <rich@phekda.gotadsl.co.uk> :
[...]
> Is the "media" part of the patch confusing?

No (it could have stored its data in link_settings[] though).

I do not understand what the "ret" variable in rtl8169_set_speed_xmii()
is supposed to do but it is not a big issue.

Style aside, Ben has imho a point. The patch adds a special case:
- is there a real need ?
- is it a 8169-specific thing or not ?

The code is added in an area where the driver is currently not pretty.
The driver should probably replace its own defines with the ones in
<linux/mii.h> then really disable autonegotiation when it is asked to
(hint, hint).

--
Ueimor
