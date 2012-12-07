From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH net-next 0/1] fix vlan transmit performance
Date: Fri, 07 Dec 2012 12:32:19 -0500
Message-ID: <50C22823.5060105@myri.com>
References: <1354827296-12009-1-git-send-email-gallatin@myri.com> <1354837321.2828.86.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:61317 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423089Ab2LGRjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 12:39:35 -0500
Received: by mail-yh0-f52.google.com with SMTP id o22so134488yho.11
        for <netdev@vger.kernel.org>; Fri, 07 Dec 2012 09:39:35 -0800 (PST)
In-Reply-To: <1354837321.2828.86.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/12 18:42, Ben Hutchings wrote:
> On Thu, 2012-12-06 at 15:54 -0500, Andrew Gallatin wrote:
<..>
>> The following patch (just copy dev->features to dev->vlan_features in
>> vlan_dev_init()) seems to be the simplest way to fix it. Perhaps this
>> is wrong, and there is a better way?
> [...]
> 
> It's wrong, because those features would then be recursively transferred
> to further stacked VLAN devices.
> 

The more I play with it & try various combinations, the more
I realize how tricky stacked vlans makes things,
so I think its best for me to just leave this alone..

Sorry for the noise.

Drew
