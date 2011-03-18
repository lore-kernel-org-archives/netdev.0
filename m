From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: SO_BINDTODEVICE inconsistency between IPv4 and IPv6
Date: Fri, 18 Mar 2011 08:54:33 +0000
Message-ID: <1300438473.16342.18.camel@macbook.infradead.org>
References: <1300357750.2589.46.camel@macbook.infradead.org>
	 <4D82B4DB.2060006@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Yuniverg, Michael" <michael.yuniverg@intel.com>,
	"Yedvab, Nadav" <nadav.yedvab@intel.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51296 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756383Ab1CRIyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 04:54:36 -0400
In-Reply-To: <4D82B4DB.2060006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-17 at 21:26 -0400, Brian Haley wrote:
> Hmm, "connection refused", do you have any iptables rules installed?  Connecting
> to a local global address worked fine for me on 2.6.32-30 using a home-grown
> test app.

Thanks for looking at this.

Just to confirm... after your server does SO_BINDTODEVICE to 'lo', your
clients on the same host can make a successful connection to global IPv6
addresses which are assigned to the *other* interfaces? 

Can you show your version of the test app, and your results? What kernel
is this on?

-- 
dwmw2

