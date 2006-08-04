From: David Miller <davem@davemloft.net>
Subject: Re: e100: checksum mismatch on 82551ER rev10
Date: Fri, 04 Aug 2006 04:28:34 -0700 (PDT)
Message-ID: <20060804.042834.78730901.davem@davemloft.net>
References: <44D0D7CA.2060001@intel.com>
	<62b0912f0608040404p59545a0asc7f5fc5f537ec32c@mail.gmail.com>
	<20060804.042024.63108922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, charlieb@budge.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:43195
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932594AbWHDL23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 07:28:29 -0400
To: molle.bestefich@gmail.com
In-Reply-To: <20060804.042024.63108922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Fri, 04 Aug 2006 04:20:24 -0700 (PDT)

> I totally agree, Intel driver maintainers generally act like complete
> idiots in these kinds of situations.
> 
> If the EEPROM has a broken checksum, the user should have an option
> that allows him to try and use the device anyways, end of story.

And BTW I want to remind the entire world that the last time Intel
cried wolf to all of us about vendors using broken EEPROMs with their
networking chips it turned out to be a bug in one of the patches Intel
put into the Linux driver. :-)

Intel should really humble themselves and help users instead of hinder
them.  Putting the blame on other vendors does not help users, I don't
care how you spin it.  It only serves to make Intel look like a bunch
of control freaks, and that pisses off users to no end.

Please put the option into the e100 driver to allow trying to use the
device even if the EEPROM checksum is wrong.

If an Intel developer doesn't do it, I will.
