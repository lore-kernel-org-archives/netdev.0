From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH] iwlwifi: pcie: fix SPLC structure parsing
Date: Thu, 13 Oct 2016 20:49:43 +0300
Message-ID: <1476380983.3880.33.camel@coelho.fi>
References: <1476349269.3880.18.camel@coelho.fi>
         <20161013102155.14547-1-luca@coelho.fi>
         <1476358075.1999.5.camel@tiscali.nl> <1476358222.3880.21.camel@coelho.fi>
         <1476362194.1999.11.camel@tiscali.nl> <1476362653.3880.25.camel@coelho.fi>
         <1476363353.1999.17.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linuxwifi@intel.com, emmanuel.grumbach@intel.com,
        johannes@sipsolutions.net, kvalo@codeaurora.org,
        oren.givon@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>, linux-wireless@vger.kernel.org,
        chris@rorvick.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from paleale.coelho.fi ([176.9.41.70]:48856 "EHLO
        farmhouse.coelho.fi" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S934401AbcJMRtx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 13:49:53 -0400
In-Reply-To: <1476363353.1999.17.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-13 at 14:55 +0200, Paul Bolle wrote:
> On Thu, 2016-10-13 at 15:44 +0300, Luca Coelho wrote:
> >  Even though there is apparently something wrong with this part of the
> > ACPI table on you laptop, since it doesn't match our specifications.
> >  In any case, it's mostly harmless.
> 
> 
> Would a correct implementation by Dell have any benefits for the users
> of these laptops? In other words: should I bother somehow contacting
> Dell and point them to this discussion in order to have them fix this?

This value provides a way for the OEM to fine tune the power budget of
the device.  This is (usually) used to prevent parts of the platform
from getting too hot.  We have a certain default that is good enough
for most cases.  If Dell didn't want to set proper limits for this
device, it probably means that it is not a concern.  Dell does set
these values correctly for other platforms.

So, I guess it's up to you if you want to clarify this with them.  This
could be some default "blank" values when they don't want to change
them.
