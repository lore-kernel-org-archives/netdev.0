From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 driver upgrade (Linux 2.6.32 -> 3.2) breaks IBM
 Bladecenter SoL
Date: Tue, 2 Oct 2012 10:06:47 -0700
Message-ID: <1349197607.5420.25.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <87txuhho5z.fsf@lant.ki.iif.hu>
 <1349083982.5420.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <87a9w5dqle.fsf@lant.ki.iif.hu>
 <1349190185.5420.21.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <87haqcddks.fsf@lant.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Matt Carlson" <mcarlson@broadcom.com>,
	"Grant Likely" <grant.likely@secretlab.ca>,
	"Rob Herring" <rob.herring@calxeda.com>,
	linux-kernel@vger.kernel.org
To: "Ferenc Wagner" <wferi@niif.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87haqcddks.fsf@lant.ki.iif.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-10-02 at 18:49 +0200, Ferenc Wagner wrote:
> Going into the opposite direction: I found that Linux 3.6 does not
> permanently break the SoL console on upping eth0!  I'll try to find
> the
> commit which (sort of) fixed it.

These are the likely fixes:
> 
commit cf9ecf4b631f649a964fa611f1a5e8874f2a76db 
Author: Matt Carlson <mcarlson@broadcom.com>
Date: Mon Nov 28 09:41:03 2011 +0000

tg3: Fix TSO CAP for 5704 devs w / ASF enabled

commit 7196cd6c3d4863000ef88b09f34d6dd75610ec3e
Author: Matt Carlson <mcarlson@broadcom.com>
Date: Thu May 19 16:02:44 2011 +0000

tg3: Add braces around 5906 workaround.
