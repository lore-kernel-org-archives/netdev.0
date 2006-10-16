From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Mon, 16 Oct 2006 11:55:16 -0700
Message-ID: <4533D594.2070908@intel.com>
References: <44AC05A8.9030503@intel.com>	 <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>	 <1152191018.5103.48.camel@jzny2>	 <20060706.235909.78729229.davem@davemloft.net> <1152275283.5341.144.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, Robert.Olsson@data.slu.se,
	john.ronciak@intel.com, greearb@candelatech.com, jgarzik@pobox.com,
	olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2333 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1422819AbWJPS5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 14:57:22 -0400
To: hadi@cyberus.ca
In-Reply-To: <1152275283.5341.144.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2006-06-07 at 23:59 -0700, David Miller wrote:
> 
>> It's autonegotiated, check you kernel message logs when the link
>> came up, you'll see this:
>>
>> tg3: eth0: Flow control is on for TX and on for RX.
>>
> 
> yikes - yes, this would be it.
> 
> I  could be wrong and i will double check:
> I think when the e1000 says via ethtool "rx is on" - it means that it 
> is _advertising_ flow control as opposed to detecting partner has flow
> control capability.
> Auke, can you also check this as well?

Just found this in my todo box - a bit late :(

yes, that appears to be the correct interpretation: we never read back the detected FC 
state from the hardware.

Auke
