From: Stephen Hemminger <shemminger@osdl.org>
Subject: sky2 1.3-rc1
Date: Wed, 3 May 2006 12:05:07 -0700
Message-ID: <20060503120507.4558c675@localhost.localdomain>
References: <1146667951.3056.25.camel@fc5test.deadmoose.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:65194 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750754AbWECT0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 15:26:25 -0400
To: Bill Hoover <bill@luminescent.com>,
	Thomas Glanzmann <sithglan@stud.uni-erlangen.de>,
	Bertrand Jacquin <beber@gna.org>, micheleschi@libero.it,
	Daniel Drake <dsd@gentoo.org>
In-Reply-To: <1146667951.3056.25.camel@fc5test.deadmoose.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is a new version that addresses some of the outstanding bugs.
* There was a race in receive processing that would cause hang
* Some more support for Yukon Ultra found in dual-core Centrino
  laptops (I want one of these).

It does not fix the problems with dual port cards corrupting receive
data (and possibly memory).

	http://developer.osdl.org/shemminger/prototypes/sky2-1.3-rc1.tar.bz2

If this works for most people, I'll post as separate patches for 2.6.17
tomorrow.
