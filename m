From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Tue, 16 Dec 2014 12:11:07 -0800
Message-ID: <549091DB.6050600@intel.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com> <54905F67.2090509@gmail.com> <54906A11.6030701@intel.com> <54908856.1070708@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51699 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375AbaLPULL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 15:11:11 -0500
In-Reply-To: <54908856.1070708@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/16/2014 11:30 AM, Roopa Prabhu wrote:
> On 12/16/14, 9:21 AM, Samudrala, Sridhar wrote:
>>
>> On 12/16/2014 8:35 AM, John Fastabend wrote:
>>>
>>>> Is there no way to get the unicast/multicast mac addresses for such
>>>> a driver?
>>>
>>> You can almost infer it from ip link by looking at all the stacked
>>> drivers and figuring out how the address are propagated down. Then
>>> look at the routes and figure out multicast address. But other than
>>> the fdb dump mechanism I don't think there is anything.
>>
>> It looks like we can get the device specific unicast/multicast mac 
>> addresses via 'ip maddr' too.
> if i remember correctly, 'ip maddr' was only for multicast list. And 
> there was no way to dump the unicast list until bridge self was 
> introduced.
> the only way to dump unicast addresses today is by using the `bridge 
> fdb show self`
Yes. 'ip maddr show' only lists the multicast macs as the name suggests. 
I stand corrected.
May be we need 'ip uaddr show' to list unicast macs instead of 
overloading 'bridge fdb show' to show unicast lists.

Thanks
Sridhar
