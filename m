From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/3] net: dsa: add MDB support
Date: Wed, 31 Aug 2016 10:22:17 -0400
Message-ID: <87vayhvx0m.fsf@ketchup.mtl.sfl>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com> <20160829203246.18811-2-vivien.didelot@savoirfairelinux.com> <20160831132534.GA15078@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48618 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934324AbcHaOWV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 10:22:21 -0400
In-Reply-To: <20160831132534.GA15078@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Mon, Aug 29, 2016 at 04:32:44PM -0400, Vivien Didelot wrote:
>> Add SWITCHDEV_OBJ_ID_PORT_MDB support to the DSA layer.
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> ---
>>  Documentation/networking/dsa/dsa.txt | 23 +++++++++++++++
>>  include/net/dsa.h                    | 16 +++++++++++
>>  net/dsa/slave.c                      | 55 ++++++++++++++++++++++++++++++++++++
>>  3 files changed, 94 insertions(+)
>> 
>> diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
>> index 44ed453..6db7bc8 100644
>> --- a/Documentation/networking/dsa/dsa.txt
>> +++ b/Documentation/networking/dsa/dsa.txt
>> @@ -584,6 +584,29 @@ of DSA, would be the its port-based VLAN, used by the associated bridge device.
>>    function that the driver has to call for each MAC address known to be behind
>>    the given port. A switchdev object is used to carry the VID and FDB info.
>>  
>> +- port_mdb_prepare: bridge layer function invoked when the bridge prepares the
>> +  installation of a multicast group database entry.
>
> Terminology question. This function is used to add a multicast MAC
> address to the switch tables. I've always considered a multicast group
> as an IP layer thing. But this documentation is also considering a
> multicast group to be a layer 2 thing.
>
> Does the bridge code use multicast group when referring to L2?

The switchdev MDB attribute is very similary to the FDB attribute. It
contains the VLAN ID and the Ethernet MAC address of the group.

Thanks,

        Vivien
