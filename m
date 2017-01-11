From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] net: dsa: Implement ndo_get_phys_port_name()
Date: Wed, 11 Jan 2017 08:28:29 +0100
Message-ID: <20170111072829.GB1852@nanopsycho>
References: <20170110203237.23907-1-f.fainelli@gmail.com>
 <20170110203237.23907-2-f.fainelli@gmail.com>
 <20170110205043.GM22820@lunn.ch>
 <60d188ef-a080-1707-9ff2-0ebfa58b81d2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        davem@davemloft.net, vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35815 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932601AbdAKH2d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 02:28:33 -0500
Received: by mail-wm0-f67.google.com with SMTP id l2so35061623wml.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 23:28:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <60d188ef-a080-1707-9ff2-0ebfa58b81d2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 10, 2017 at 09:58:53PM CET, f.fainelli@gmail.com wrote:
>On 01/10/2017 12:50 PM, Andrew Lunn wrote:
>> On Tue, Jan 10, 2017 at 12:32:36PM -0800, Florian Fainelli wrote:
>>> Return the physical port number of a DSA created network device using
>>> ndo_get_phys_port_name().
>> 
>> At what level does this need to be unique?
>
>This needs to be unique to the switch I would say,

Yes.

>ndo_get_phys_switch_id would return the physical number of the switch
>device in the tree/cluster, so that number plus the port name should be
>an unique differentiator that is good enough for e.g: a persistent
>naming rule?

Yes.

>
>> 
>> We can have multiple switches within one switch cluster. p->port will
>> be unique within one switch, but can be repeated in a cluster.
>> 
>> We can also have multiple clusters, and again p->port will be re-used.
>
>
>-- 
>Florian
