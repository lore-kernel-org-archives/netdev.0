From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: Implement ndo_get_phys_port_name()
Date: Tue, 10 Jan 2017 12:58:53 -0800
Message-ID: <60d188ef-a080-1707-9ff2-0ebfa58b81d2@gmail.com>
References: <20170110203237.23907-1-f.fainelli@gmail.com>
 <20170110203237.23907-2-f.fainelli@gmail.com>
 <20170110205043.GM22820@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34861 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbdAJU6z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:58:55 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so11523942pfa.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 12:58:55 -0800 (PST)
In-Reply-To: <20170110205043.GM22820@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2017 12:50 PM, Andrew Lunn wrote:
> On Tue, Jan 10, 2017 at 12:32:36PM -0800, Florian Fainelli wrote:
>> Return the physical port number of a DSA created network device using
>> ndo_get_phys_port_name().
> 
> At what level does this need to be unique?

This needs to be unique to the switch I would say,
ndo_get_phys_switch_id would return the physical number of the switch
device in the tree/cluster, so that number plus the port name should be
an unique differentiator that is good enough for e.g: a persistent
naming rule?

> 
> We can have multiple switches within one switch cluster. p->port will
> be unique within one switch, but can be repeated in a cluster.
> 
> We can also have multiple clusters, and again p->port will be re-used.


-- 
Florian
