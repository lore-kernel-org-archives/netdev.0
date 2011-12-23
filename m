From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] bna: Added flash sub-module and ethtool eeprom
 entry points.
Date: Fri, 23 Dec 2011 09:44:22 +0000
Message-ID: <1324633462.3860.6.camel@deadeye>
References: <1324596585-8614-1-git-send-email-kgudipat@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@brocade.com>, <rmody@brocade.com>
To: <kgudipat@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:58480 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751664Ab1LWJom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 04:44:42 -0500
In-Reply-To: <1324596585-8614-1-git-send-email-kgudipat@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-12-22 at 15:29 -0800, kgudipat@brocade.com wrote:
> From: Krishna Gudipati <kgudipat@brocade.com>
> 
> Change details:
> 	- The patch adds flash sub-module to the bna driver.
> 	- Added ethtool set_eeprom() and get_eeprom() entry points to
> 	  support flash partition read/write operations.
[...]

I'm not going to say this is wrong, but we didn't find the EEPROM
operations suitable for firmware upgrade.  I have a couple of questions:

1. How long can a single set_eeprom() operation take?
2. Have you considered implementing the flash_device() operation or an
MTD driver?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
