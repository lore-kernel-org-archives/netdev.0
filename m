From: Joe Perches <joe@perches.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/1] igb: Use ARRAY_SIZE instead fo
 sizeof(a)/sizeof(a[0])
Date: Tue, 30 Jun 2015 13:52:30 -0700
Message-ID: <1435697550.12101.33.camel@perches.com>
References: <1435640130-1466-1-git-send-email-maninder1.s@samsung.com>
	 <9B4A1B1917080E46B64F07F2989DADD653571921@ORSMSX114.amr.corp.intel.com>
	 <CAFLxGvxayeac0Hq8Gi5j_TJ4dnboYypz9gchW0VQ0Z9t-UFofA@mail.gmail.com>
	 <9B4A1B1917080E46B64F07F2989DADD653571BF0@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard.weinberger@gmail.com>,
	Maninder Singh <maninder1.s@samsung.com>,
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
Received: from smtprelay0190.hostedemail.com ([216.40.44.190]:45962 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751042AbbF3Uwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 16:52:35 -0400
In-Reply-To: <9B4A1B1917080E46B64F07F2989DADD653571BF0@ORSMSX114.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-30 at 20:16 +0000, Fujinaka, Todd wrote:
> Sorry for the top-posting, but I'm provided with the tools they give me
> and bottom posting from Outlook just confuses email threads. Plus, this
> was crossposted all over creation and cc-ed to anyone with an intel
> address.

Not quite.  It was posted to the names listed under the
MAINTAINERS entry.

INTEL ETHERNET DRIVERS
M:	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
R:	Jesse Brandeburg <jesse.brandeburg@intel.com>
R:	Shannon Nelson <shannon.nelson@intel.com>
R:	Carolyn Wyborny <carolyn.wyborny@intel.com>
R:	Don Skidmore <donald.c.skidmore@intel.com>
R:	Matthew Vick <matthew.vick@intel.com>
R:	John Ronciak <john.ronciak@intel.com>
R:	Mitch Williams <mitch.a.williams@intel.com>
L:	intel-wired-lan@lists.osuosl.org

btw: You aren't listed there Todd.  Should you be?

> I still would say no if I'm allowed, because to guarantee that this
> change - that I don't think fixes anything

Simplicity for the reader is generally a good thing.
Removing the macros altogether is likely better.

>  - works in all cases, we
> need to do an incredible amount of regression testing.

Compilers should not produce different object code.
Verification of no object changes should be good enough.

> Every variant of
> every Intel part that uses this driver (and there are many) should be
> tested and will end up being used by the community.
> 
> Plus, you have no idea the number of obscure bugs I have to deal with
> as the guy answering customer questions. If this triggers some odd
> embedded compiler bug, I'm going to have to dig it out. Unless there is
> an actual bug, I'd like to leave it as it is.

If any compiler miscompiles the ARRAY_SIZE macro, there are bound to
be real issues with using that compiler in a production environment.
