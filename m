From: Paul Smith <psmith@netezza.com>
Subject: Re: NET_POLL missing in the new ibm_emac driver?
Date: Tue, 10 Apr 2007 18:04:00 -0400
Message-ID: <1176242640.13662.124.camel@psmithub>
Reply-To: psmith@netezza.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linuxppc-embedded@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mr1.netezza.com ([12.148.248.137]:58999 "HELO mail2.netezza.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753943AbXDJWED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 18:04:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all; any love here?  Maybe a pointer or two (e.g., what's the
equivalent, in the new emac driver, of these lines in the old driver:

	emac_rxeob_dev((void *)ndev, 0);
	emac_txeob_dev((void *)ndev, 0);

?)

---------------

I was having so many problems with the 2.6.14 (old) emac driver that I
backported the new one from 2.6.15.  It works great... until I tried to
use KGDBOE with it.  Then I got:

    kgdboe: eth1 doesn't support polling, aborting.

Looking around I see that I need the driver to support the
poll_controller method in the net device, and the new driver doesn't
seem to do that.

I see the old implementation of this method, but of course it uses
interfaces that no longer exist so I can't use that directly.  It seems
like a small change but I'm not really familiar with the implementation
of the ibm_emac driver; does anyone have a patch for the new driver to
provide this feature?


Thanks!

-- 
-----------------------------------------------------------------------------
 Paul D. Smith <psmith@netezza.com>                       http://netezza.com
 "Please remain calm--I may be mad, but I am a professional."--Mad Scientist
-----------------------------------------------------------------------------
      These are my opinions--Netezza takes no responsibility for them.
