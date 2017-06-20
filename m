From: John Crispin <john@phrozen.org>
Subject: Re: [RFC 2/2] net-next: mt7530: add nh and proto offsets to the ops
 struct
Date: Tue, 20 Jun 2017 19:27:23 +0200
Message-ID: <0c30b590-19b1-8648-eea1-943724c60941@phrozen.org>
References: <20170620080655.7251-1-john@phrozen.org>
 <20170620080655.7251-2-john@phrozen.org> <20170620135439.GA12383@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:54210 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751025AbdFTR1z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 13:27:55 -0400
In-Reply-To: <20170620135439.GA12383@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 20/06/17 15:54, Andrew Lunn wrote:
> On Tue, Jun 20, 2017 at 10:06:55AM +0200, John Crispin wrote:
>> The MT7530 inserts the 4 magic header in between the 802.3 address and
>> protocol field. The patch defines these header such that the flow_disector
>> can properly parse the packet and thus allows hashing to function properly.
> This is to do with tagging, not the switch driver. The Marvell switch
> driver can be used with two different tagging protocols.
>
> So i would put these fields in the dsa_device_ops.
>
>     Andrew
Hi Andrew,

i originally did so but struct dsa_device_ops is defined inside 
net/dsa/dsa_priv.h so flow_dissector.c would need a

#include "../dsa/dsa_priv.h"

I was not sure if this is ok or if we would need to move the struct 
definition to include/net/dsa.h in that case

     John
