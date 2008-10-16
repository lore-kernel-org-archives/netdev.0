From: "Hillier, Gernot" <gernot.hillier@siemens.com>
Subject: Re: e1000e: sporadic "hardware error"s with Intel 82563EB on Supermicro
 X7DB3
Date: Thu, 16 Oct 2008 18:07:39 +0200
Message-ID: <48F766CB.3030603@siemens.com>
References: <EA929A9653AAE14F841771FB1DE5A1365F498F4EDC@rrsmsx501.amr.corp.intel.com> <E3627BC91D010645BD262A1E8720005106A64162@orsmsx420.amr.corp.intel.com> <48EE04C0.6070504@siemens.com> <48F463D1.70605@siemens.com> <E3627BC91D010645BD262A1E8720005106B67989@orsmsx420.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Hockert, Jeff W" <jeff.w.hockert@intel.com>
To: "Graham, David" <david.graham@intel.com>,
	"Fodor, Zoltan" <zoltan.fodor@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755582AbYJPQCo@vger.kernel.org>
In-Reply-To: <E3627BC91D010645BD262A1E8720005106B67989@orsmsx420.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there!

Graham, David wrote:
> It would help if you could provide a little more information. Could you
> provide (for one of each of the two configurations that you have - one
> with the IPMI card, one without):
> 
> 	lspci -t
> 	lspci -vvv -xxxx
> 	ethtool -e eth0

Ok, it turned out that we still can reproduce the problem - even after the
firmware upgrade. So I collected the information you requested from two
machines:

- BVSIM3 is the one with the IPMI card.
- BVSIM5 the one without the IPMI card.

As the output from the commands you requested is rather large, I uploaded
it to the following URLs instead posting it to the list, hope that's ok:

http://www.hillier.de/bvsim5-ethtool-e.txt
http://www.hillier.de/bvsim5-lspci-t.txt
http://www.hillier.de/bvsim5-lspci-vvv-xxxx.txt
http://www.hillier.de/bvsim3-ethtool-e.txt
http://www.hillier.de/bvsim3-lspci-t.txt
http://www.hillier.de/bvsim3-lspci-vvv-xxxx.txt

All commands were run in the error case, i.e. after e1000e said "Hardware
error".

> 	BIOS "IPMI" menus (I know you already gave us one, but both
> would be good)

BVSIM3 shows the IPMI menu I already provided
BVSIM5 shows no IPMI menu

Thanks in advance!

-- 
With kind regards,
Gernot Hillier
Siemens AG, CT SE 2, Corporate Competence Center Embedded Linux
