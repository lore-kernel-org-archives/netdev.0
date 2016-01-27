From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH net 2/2] DT: phy.txt: Clarify expected compatible values
Date: Wed, 27 Jan 2016 08:41:56 -0800
Message-ID: <CAOesGMj6OKYY6thjKX_t-ABogSNrSuQ7rbWPPvhGRtdOTJtXiQ@mail.gmail.com>
References: <1453853499-11248-1-git-send-email-andrew@lunn.ch>
	<1453853499-11248-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Aaro Koskinen <aaro.koskinen@nokia.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f195.google.com ([209.85.160.195]:36326 "EHLO
	mail-yk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932158AbcA0Ql5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 11:41:57 -0500
Received: by mail-yk0-f195.google.com with SMTP id k129so995340yke.3
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 08:41:56 -0800 (PST)
In-Reply-To: <1453853499-11248-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 26, 2016 at 4:11 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> PHY devices may only list clause 22, 45, and their PHY identifier
> values as compatible values. No other compatible strings are allowed.
> Make this clear in the documentation, and remove examples where
> make/model compatible strings are listed.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

I'm not sure I agree with the disallowing here. It's common practice
to use a specific compatible to describe the actual hardware used, in
case it's needed in the future for some driver to distinguish
behavior, etc.

So while it should be required to include the clause compats, having a
more specific one in there should be acceptable.


-Olof
