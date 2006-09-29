From: Joerg Roedel <joro-lkml@zlug.org>
Subject: Re: [PATH] Allow mtu bigger than 1500 for ieee80211
Date: Fri, 29 Sep 2006 17:47:51 +0200
Message-ID: <20060929154751.GA23067@zlug.org>
References: <451C0D05.4050705@free.fr> <1159515501.2644.3.camel@ux156> <20060929093050.GA19115@zlug.org> <1159530970.2644.21.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matthieu castet <castet.matthieu@free.fr>, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport-c10.fh-zwickau.de ([141.32.72.200]:60089 "EHLO
	ironport-c10.fh-zwickau.de") by vger.kernel.org with ESMTP
	id S932304AbWI2Prx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 11:47:53 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1159530970.2644.21.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 29, 2006 at 01:56:10PM +0200, Johannes Berg wrote:
> On Fri, 2006-09-29 at 11:30 +0200, Joerg Roedel wrote:

> > Isn't 68 the minimum MTU required by IPv4?
> 
> No idea, but shouldn't there be a named constant somewhere for that
> then?

Maybe. Other network drivers also implement this number as a hard value
in their change_mtu callback. For example, the default ethernet function
is implemented this way.

Joerg
