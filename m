From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v3 00/15] net: dsa: Fixes and enhancements
Date: Wed, 29 Oct 2014 14:39:28 -0700
Message-ID: <20141029213928.GA28498@roeck-us.net>
References: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
 <5451305B.7010303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:50018 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755312AbaJ2Vje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 17:39:34 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1Xjaxp-003m7v-6i
	for netdev@vger.kernel.org; Wed, 29 Oct 2014 21:39:33 +0000
Content-Disposition: inline
In-Reply-To: <5451305B.7010303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2014 at 11:22:19AM -0700, Florian Fainelli wrote:
> On 10/29/2014 10:44 AM, Guenter Roeck wrote:
> > Patch 01/15 addresses a bug indicated by an an annoying and unhelpful
> > log message.
> > 
> > Patches 02/15 and 03/15 are minor enhancements, adding support for
> > known switch revisions.
> > 
> > Patches 04/15 and 05/15 add support for MV88E6352 and MV88E6176.
> > 
> > Patch 06/15 adds support for hardware monitoring, specifically for
> > reporting the chip temperature, to the dsa subsystem.
> > 
> > Patches 07/15 and 08/15 implement hardware monitoring for MV88E6352,
> > MV88E6176, MV88E6123, MV88E6161, and MV88E6165.
> > 
> > Patch 09/15 and 10/15 add support for EEPROM access to the DSA subsystem.
> > 
> > Patch 11/15 implements EEPROM access for MV88E6352 and MV88E6176.
> > 
> > Patch 12/15 adds support for reading switch registers to the DSA
> > subsystem.
> > 
> > Patches 13/15 amd 14/15 implement support for reading switch registers
> > to the drivers for MV88E6352, MV88E6176, MV88E6123, MV88E6161, and MV88E6165.
> > 
> > Patch 15/15 adds support for reading additional RMON registers to the drivers
> > for  MV88E6352, MV88E6176, MV88E6123, MV88E6161, and MV88E6165.
> > 
> > The series was tested on top of v3.18-rc2 in an x86 system with MV88E6352.
> > Testing in systems with 88E6131, 88E6060 and MV88E6165 was done earlier
> > (I don't have access to those systems right now). The series was also build
> > tested using my build system at http://server.roeck-us.net:8010/builders.
> > Look into the 'dsa' column for build results.
> > 
> > The series merges cleanly into net-next as of today (10/29).
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Thanks Guenter!
> 
Thanks a lot for the review!

Guenter
