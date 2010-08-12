From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: e1000e crashes with 2.6.34.x and ThinkPad T60
Date: Thu, 12 Aug 2010 12:50:29 +0200
Message-ID: <20100812105029.GA6816@torres.zugschlus.de>
References: <20100724092644.GA13353@torres.zugschlus.de> <EA929A9653AAE14F841771FB1DE5A1366000F42E28@rrsmsx501.amr.corp.intel.com> <20100730125452.GA21444@torres.zugschlus.de> <EA929A9653AAE14F841771FB1DE5A13660024083FE@rrsmsx501.amr.corp.intel.com> <20100810120458.GB21511@torres.zugschlus.de> <8DD2590731AB5D4C9DBF71A877482A900164D9279F@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:34679 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759764Ab0HLKuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 06:50:32 -0400
Content-Disposition: inline
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A900164D9279F@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Aug 10, 2010 at 09:34:52AM -0700, Allan, Bruce W wrote:
> [adding e1000-devel, the Intel wired ethernet developers mailing list]

Thanks.

> We have had other recent reports of issues with this part that are due to
> ASPM L1 being enabled.  Would you please try disabling L1 after the driver
> is loaded as follows (assuming your adapter is still PCI bus/device/number
> 02:00.0 as indicated in the lspci output you provided earlier):
> 1) First check the hexadecimal value of the LnkCtl register -
> # setpci -s 2:0.0 0xf0

$ sudo setpci --version
setpci version 3.1.7                   
$ sudo setpci -s 2:0.0 0xf0
setpci: Missing width.
Try `setpci --help' for more information.
$

Looking at --help doesn't help me, sorry.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
