From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: e1000e crashes with 2.6.34.x and ThinkPad T60
Date: Fri, 13 Aug 2010 10:07:36 +0200
Message-ID: <20100813080736.GA912__7961.69530735842$1281686884$gmane$org@torres.zugschlus.de>
References: <20100724092644.GA13353@torres.zugschlus.de> <EA929A9653AAE14F841771FB1DE5A1366000F42E28@rrsmsx501.amr.corp.intel.com> <20100730125452.GA21444@torres.zugschlus.de> <EA929A9653AAE14F841771FB1DE5A13660024083FE@rrsmsx501.amr.corp.intel.com> <20100810120458.GB21511@torres.zugschlus.de> <8DD2590731AB5D4C9DBF71A877482A900164D9279F@orsmsx509.amr.corp.intel.com> <20100813012551.GA25398@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <ne
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:56664 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761350Ab0HMIHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 04:07:38 -0400
Content-Disposition: inline
In-Reply-To: <20100813012551.GA25398@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 13, 2010 at 03:25:51AM +0200, Marc Haber wrote:
> On Tue, Aug 10, 2010 at 09:34:52AM -0700, Allan, Bruce W wrote:
> > We have had other recent reports of issues with this part that are due to
> > ASPM L1 being enabled.  Would you please try disabling L1 after the driver
> > is loaded as follows (assuming your adapter is still PCI bus/device/number
> > 02:00.0 as indicated in the lspci output you provided earlier):
> > 1) First check the hexadecimal value of the LnkCtl register -
> > # setpci -s 2:0.0 0xf0
> > 2) Disable ASPM (both L0s and L1) by zeroing out bits 0 and 1 in the value
> > returned by the previous step.  For example, if it returned 42 (hex 42,
> > that is) -
> > # setpci -s 2:0.0 0xf0=0x40
> > 3) Confirm ASPM is disabled by checking the output from lspci again.
> 
> It returned 42, and after setting 0x40, LnkCtl now says "ASPM Disabled".
> 
> I'll dock the system now and will report after the weekend or after
> the first crash.

Didn't work, freeze within the first 60 minutes after starting serious
work. The system did sit idle for the night though without freezing.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
