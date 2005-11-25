From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: Mouse issues in -mm
Date: Fri, 25 Nov 2005 17:31:36 -0500
Message-ID: <200511251731.36939.dtor_core@ameritech.net>
References: <20051123033550.00d6a6e8.akpm@osdl.org> <200511232226.44459.dtor_core@ameritech.net> <43855A50.80808@tuxrocks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>,
	Marc Koschewski <marc@osknowledge.org>,
	linux-kernel@vger.kernel.org, Harald Welte <laforge@netfilter.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932218AbVKYWbn@vger.kernel.org>
To: Frank Sorenson <frank@tuxrocks.com>
In-Reply-To: <43855A50.80808@tuxrocks.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 24 November 2005 01:14, Frank Sorenson wrote:
> Note: I believe this issue may also be related to the mouse protocol
> extension. =A0I typically run with 'psmouse.proto=3Dexps' on the kern=
el
> command line, and the psmouse resync patch seems to break tapping in
> that mode.

So the resync patch - is it only tapping that is broken or you also
loosing the touchpad completely?

> However, booting without proto=3Dexps seems to continue to=20
> work, even with the resync patch (though the touchpad is unusably
> sensitive--hence the use of exps in the first place).

Without the parameter your touchpad is using native ALPS protocol and
resync is disabled for it. You may have better liuck with toucpad
sensitivity using synaptics X driver.

--=20
Dmitry
