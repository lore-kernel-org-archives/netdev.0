From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: Porting the ibm_newemac driver to use phylib (and other PHY/MAC
	questions)
Date: Mon, 20 Apr 2009 20:10:05 -0400
Message-ID: <f73f7ab80904201710m57472291yf7ff86760977b8e8@mail.gmail.com>
References: <f73f7ab80904171732n41832d0hc62978e57bbcc32e@mail.gmail.com>
	 <625fc13d0904200529l152b8d75g33c3f940de1b2920@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linuxppc-dev@ozlabs.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:17864 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbZDUAKG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 20:10:06 -0400
In-Reply-To: <625fc13d0904200529l152b8d75g33c3f940de1b2920@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 20, 2009 at 8:29 AM, Josh Boyer <jwboyer@linux.vnet.ibm.com=
> wrote:
> On Fri, Apr 17, 2009 at 8:32 PM, Kyle Moffett <kyle@moffetthome.net> =
wrote:
>> Hello,
>>
>> I'm currently fiddling with a custom embedded prototype board using
>> the ibm_newemac driver with some currently-unsupported PHYs. =C2=A0T=
hose
>> PHYs *are* supported by phylib, but the emac driver seems to have it=
s
>> own PHY layer cribbed from the sungem driver. =C2=A0I'm curious if t=
here's
>> some particular reason it hasn't been ported (aside from "nobody has
>> bothered yet").
>
> IIRC, Ben had some issues with how phylib and the EMAC would need to
> interact. =C2=A0Not sure if he has those written down somewhere or no=
t.
> (CC'd).

Hmm, yeah, I'd be interested to see those.  There's enough similar
between phylib and the EMAC and sungem drivers that I'm considering a
series of somewhat-mechanical patches to make EMAC and sungem use the
"struct phy_device" and "struct mii_bus" from phylib, possibly
abstracting out some helper functions along the way.

>> Also, if I end up
>> going that route, are there others available with other hardware
>> variants who would be willing to test my patches on their boards?
>
> I have a large variety of boards that I can test with since the entir=
e
> 4xx line relies on this driver for on-board network.

Wonderful!  If/when I hack together a patch series I'll make sure to
put you on the CC list.  Thanks!

Cheers,
Kyle Moffett
