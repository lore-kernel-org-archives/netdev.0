From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: document missing functions
Date: Tue, 05 Apr 2016 22:02:25 -0400
Message-ID: <87h9ffxzny.fsf@ketchup.mtl.sfl>
References: <1459869760-23295-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20160405233943.GA19409@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160405233943.GA19409@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Tue, Apr 05, 2016 at 11:22:40AM -0400, Vivien Didelot wrote:
>> Add description for the missing port_vlan_prepare, port_fdb_prepare,
>> port_fdb_dump functions in the DSA documentation.
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>
> Hi Vivien
>
> A few English improvements:
>
>> ---
>>  Documentation/networking/dsa/dsa.txt | 16 ++++++++++++++++
>>  1 file changed, 16 insertions(+)
>> 
>> diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
>> index 3b196c3..8ba3369 100644
>> --- a/Documentation/networking/dsa/dsa.txt
>> +++ b/Documentation/networking/dsa/dsa.txt
>> @@ -542,6 +542,12 @@ Bridge layer
>>  Bridge VLAN filtering
>>  ---------------------
>>  
>> +- port_vlan_prepare: bridge layer function invoked when the bridge prepares the
>> +  configuration of a VLAN on the given port. If the operation is not
>> +  programmable, this function should return -EOPNOTSUPP to inform the bridge
>
> s/programmable/supported by the hardware
>
>> +  code to fallback to a software implementation. No hardware programmation
>
> s/programmation/setup
>
>> +  must be done in this function. See port_vlan_add for this and details.
>> +
>>  - port_vlan_add: bridge layer function invoked when a VLAN is configured
>>    (tagged or untagged) for the given switch port
>>  
>> @@ -552,6 +558,12 @@ Bridge VLAN filtering
>>    function that the driver has to call for each VLAN the given port is a member
>>    of. A switchdev object is used to carry the VID and bridge flags.
>>  
>> +- port_fdb_prepare: bridge layer function invoked when the bridge prepares the
>> +  installation of a Forwarding Database entry. If the operation is not
>> +  programmable, this function should return -EOPNOTSUPP to inform the bridge
>
> s/programmable/supported
>
>> +  code to fallback to a software implementation. No hardware programmation
>
> s/programmation/setup

Done, v2 on its way.

Thanks,
Vivien
