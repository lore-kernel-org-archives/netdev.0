From: Richard Weinberger <richard@nod.at>
Subject: Re: [Intel-wired-lan] [PATCH 1/1] igb: Use ARRAY_SIZE instead fo
 sizeof(a)/sizeof(a[0])
Date: Tue, 30 Jun 2015 22:24:14 +0200
Message-ID: <5592FAEE.5020000@nod.at>
References: <1435640130-1466-1-git-send-email-maninder1.s@samsung.com>	<9B4A1B1917080E46B64F07F2989DADD653571921@ORSMSX114.amr.corp.intel.com> <CAFLxGvxayeac0Hq8Gi5j_TJ4dnboYypz9gchW0VQ0Z9t-UFofA@mail.gmail.com> <9B4A1B1917080E46B64F07F2989DADD653571BF0@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Maninder Singh <maninder1.s@samsung.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"pankaj.m@samsung.com" <pankaj.m@samsung.com>
To: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.ns.miles-group.at ([95.130.255.143]:65276 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752812AbbF3UYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2015 16:24:20 -0400
In-Reply-To: <9B4A1B1917080E46B64F07F2989DADD653571BF0@ORSMSX114.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Am 30.06.2015 um 22:16 schrieb Fujinaka, Todd:
> Sorry for the top-posting, but I'm provided with the tools they give me and bottom posting from Outlook just confuses email threads. Plus, this was crossposted all over creation and cc-ed to anyone with an intel address.
> 
> I still would say no if I'm allowed, because to guarantee that this change - that I don't think fixes anything - works in all cases, we need to do an incredible amount of regression testing. Every variant of every Intel part that uses this driver (and there are many) should be tested and will end up being used by the community.
> 
> Plus, you have no idea the number of obscure bugs I have to deal with as the guy answering customer questions. If this triggers some odd embedded compiler bug, I'm going to have to dig it out. Unless there is an actual bug, I'd like to leave it as it is.

If you don't dare to touch your driver please update it's maintenance status.
"Supported" is definitely not the case, maybe "Odd fixes" would fit better.

Thanks,
//richard
