From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: bridge carrier issue
Date: Sun, 25 Sep 2011 10:51:04 +0200
Message-ID: <20110925085104.GB32712@torres.zugschlus.de>
References: <20110920.152953.448244771460257273.davem@redhat.com>
 <c1e52584-2b98-4e95-bfb1-fe4cd64c1c47@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:33768 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489Ab1IYIvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2011 04:51:06 -0400
Received: from mh by torres.zugschlus.de with local (Exim 4.72)
	(envelope-from <mh+netdev@zugschlus.de>)
	id 1R7kQS-00009i-IP
	for netdev@vger.kernel.org; Sun, 25 Sep 2011 10:51:04 +0200
Content-Disposition: inline
In-Reply-To: <c1e52584-2b98-4e95-bfb1-fe4cd64c1c47@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2011 at 04:00:18PM -0700, Stephen Hemminger wrote:
> Looked at dnsmasq and it needs some more work to handle IPv6 address
> correctly. It sleeps if it gets a tentative address.
> 
> radvd probably has similar issues.

And bind. And libvirtd. And apache. And probably a truckload of other
applications.

The ONLY application that I am aware of and that handles this case
properly is ntpd.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
