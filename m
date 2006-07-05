From: Auke Kok <sofar@foo-projects.org>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Wed, 05 Jul 2006 14:13:30 -0700
Message-ID: <44AC2B7A.2050702@foo-projects.org>
References: <1152033116.5276.22.camel@jzny2> <1152040839.5276.25.camel@jzny2> <20060705.112237.41652489.davem@davemloft.net> <44AC05A8.9030503@intel.com> <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	Robert.Olsson@data.slu.se, john.ronciak@intel.com,
	greearb@candelatech.com, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:50585 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S964974AbWGEVmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 17:42:24 -0400
To: Krzysztof Oledzki <olel@ans.pl>
In-Reply-To: <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Oledzki wrote:
> 
> 
> On Wed, 5 Jul 2006, Auke Kok wrote:
> 
>> David Miller wrote:
>>> From: jamal <hadi@cyberus.ca>
>>> Date: Tue, 04 Jul 2006 15:20:39 -0400
>>>
>>>> BTW, As an addendum this default behavior changed around 2.6.16 it
>>>> seems.
>>>
>>> Flow control has been on by default in the tg3 driver since the
>>> beginning, maybe e1000 only recently started to behave that way
>>> but it's the right thing to do IMHO.
>>
>> As said earlier, e1000 always honors the EEPROM setting for this, 
>> which has been _on_ by default for all cards (AFAIK, that is).
> 
> I'm not sure:
> 
> root@r1:~# ethtool -d eth0|grep flow
>       Receive flow control:              disabled
>       Transmit flow control:             disabled
> root@r2:~# ethtool -d eth0|grep flow
>       Receive flow control:              enabled
>       Transmit flow control:             enabled


Same physical NIC or different ones? In the latter case your NICs may have 
different EEPROM settings. You can dump the EEPROM and compare, do something 
like `ethtool -e eth0 raw on length 64| hexdump` for both interfaces and send 
it to me. Only the first 64 bytes should matter.

Cheers,

Auke
