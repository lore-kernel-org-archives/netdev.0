From: Casey Leedom <leedom@chelsio.com>
Subject: RE: [PATCH net-next 1/3] cxgb4: Add support for loopback between VI
 of same port
Date: Fri, 22 May 2015 16:49:03 +0000
Message-ID: <4985EFDD773FCB459EF7915D2A3621ADBDA809@nice.asicdesigners.com>
References: <1431859523-7423-2-git-send-email-hariprasad@chelsio.com>
	<20150517.234613.463972132331185537.davem@davemloft.net>
	<4985EFDD773FCB459EF7915D2A3621ADBD9FE5@nice.asicdesigners.com>,<20150521.153029.774385014187583893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Hariprasad S <hariprasad@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4807 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757719AbbEVQtI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 12:49:08 -0400
In-Reply-To: <20150521.153029.774385014187583893.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: David Miller [davem@davemloft.net]
| Sent: Thursday, May 21, 2015 12:30 PM
| 
| The prevailing assumption is that it's OK to have configuration
| settings that can't be undone.
| 
| And that's bogus from the beginning.

  Oh I definitely understand that and agree.  Unfortunately I've
inherited a driver architecture that makes that ... "difficult"
for many operations ...  And I have an internal bug filed
against me to fix those particular issues.

  However, that doesn't answer at least one of my questions
which was how do I pass information into the driver _before_
it does the device probe?  In this case, telling it to _not_
attempt to attached to the chip firmware in order to debug,
load firmware, etc.?

  And, I still need to know what mechanism we need to use
to tell the driver to use one kind of transmit functionality
or another.  [[And in this case, we _can_ switch back and
forth at will.]]

Casey