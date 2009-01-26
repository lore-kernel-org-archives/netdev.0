From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: hardware time stamping with optional structs in data area
Date: Mon, 26 Jan 2009 21:39:52 +0100
Message-ID: <1233002392.23161.6.camel@pohly-MOBL>
References: <1232102164.18762.72.camel@pohly-MOBL>
	 <20090116.110033.163815590.davem@davemloft.net>
	 <1232532457.7829.19.camel@ecld0pohly>
	 <20090125.210442.129666692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1510 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752950AbZAZUkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 15:40:00 -0500
In-Reply-To: <20090125.210442.129666692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-01-26 at 07:04 +0200, David Miller wrote:
> From: Patrick Ohly <patrick.ohly@intel.com>
> Date: Wed, 21 Jan 2009 11:07:37 +0100
> See fs/compat_ioctl.c:dev_ifsioc() for how to handle the
> "32-bit process under 64-bit kernel" issue wrt. struct ifreq

Thanks, will do.

> Just consolidate the array into a direct conversion table.  You only
> have 2 bits defined so you only need an array of 4 entries.  Pass the
> optional flag bits directly in as the index of that table.

How can I get some code executed during the initialization of the IP
stack which initializes the table, before any sk_buff gets allocated?

The content is constant, but writing it down as static initializers
using just preprocessor macros would be difficult and/or ugly - that's
why I haven't done it already.

Bye, Patrick

