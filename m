From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Wed, 18 Oct 2006 07:57:32 -0700
Message-ID: <453640DC.6050103@intel.com>
References: <44AC05A8.9030503@intel.com>	 <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>	 <1152191018.5103.48.camel@jzny2>	 <20060706.235909.78729229.davem@davemloft.net>	 <1152275283.5341.144.camel@jzny2>  <4533D594.2070908@intel.com>	 <1161090331.5555.10.camel@jzny2>  <453544EF.4000502@intel.com> <1161178540.5240.16.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, Robert.Olsson@data.slu.se,
	john.ronciak@intel.com, greearb@candelatech.com, jgarzik@pobox.com,
	olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1200 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1161112AbWJRPA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:00:26 -0400
To: hadi@cyberus.ca
In-Reply-To: <1161178540.5240.16.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Tue, 2006-17-10 at 14:02 -0700, Auke Kok wrote:
> 
>> For now, we should really report the FC status in e1000 at link up time. Jamal: this 
>> should help you out for now, I'll send something like this upstream later on.
>>
> 
> Thanks - this puts you at par with the tg3 at least.
> 
> 
> On Tue, 2006-17-10 at 14:46 -0700, David Miller wrote: 
>> From: jamal <hadi@cyberus.ca>
>> Date: Tue, 17 Oct 2006 09:05:31 -0400
>>
>>> It sounds to me that ethttool needs to have this semantic fix.
>>> IOW, ethttool doesnt differentiate the two items:
>>> a) advertised parameters.
>>> b) link partner negotiated parameters.
>>>
>>> and instead #a becomes #b after negotiation.
>>>
>>>
>>> methinks this needs fixing. Dave? Jeff?
>> The way I understand it the ethernet autonegotiation mechanisms don't
>> really give you a way to seperate these two things.
>>
>> Either you negotiate the link and flow control settings, or nothing.
> 
> True - but I was thinking more of the state stored in the driver
> either by ethtool or some other part of the driver.
> 
> If i remember correctly, Donald Beckers old mii tool was able to 
> display
> "here's what you have configured the driver for link and flow control and 
> these are what i advertise to link peers"
> and
> "here's what current negotiated link and flow control parameters with 
> link peer"
> 
> That distinction doesnt exist with ethtool. Or i am missing something.

nope, there's not even an ethtool cmd to query for that data AFAICS

Auke
