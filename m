From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 16:10:45 -0800
Message-ID: <CA+55aFxJif2pQ-or78+kiW2vH43ek-z+NK_vqF9_PMuavSNE7w@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <1326302130.2705.3.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42130 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102Ab2ALALI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 19:11:08 -0500
Received: by wgbds12 with SMTP id ds12so1165737wgb.1
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 16:11:06 -0800 (PST)
In-Reply-To: <1326302130.2705.3.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 9:15 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>
> Maybe BRCMSMAC should select BCMA rather than depending on it. =A0Thi=
s bus
> seems like kind of an implementation detail that people are unlikely =
to
> be aware of, unlike say PCI.

Yes, please. This is exactly the kind of thing "select" exists for.
Asking the user about some crazy proprietary broadcom bus interface is
useless, since no sane user should ever know or care about that kind
of thing.

                         Linus
