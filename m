From: Roopa Prabhu <roprabhu@cisco.com>
Subject: Re: [net-next-2.6 PATCH 0/3 RFC] macvlan: MAC Address filtering
 support for passthru mode
Date: Mon, 12 Sep 2011 06:38:00 -0700
Message-ID: <CA935948.33E98%roprabhu@cisco.com>
References: <20110911185238.GB4740@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <dragos.tatulea@gmail.com>,
	<arnd@arndb.de>, <dwang2@cisco.com>, <benve@cisco.com>,
	<kaber@trash.net>, <sri@us.ibm.com>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <mchan@broadcom.com>,
	<kvm@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:43300 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755885Ab1ILNiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 09:38:04 -0400
In-Reply-To: <20110911185238.GB4740@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On 9/11/11 11:52 AM, "Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Sun, Sep 11, 2011 at 06:18:02AM -0700, Roopa Prabhu wrote:
>> 
>> 
>> 
>> On 9/11/11 2:38 AM, "Michael S. Tsirkin" <mst@redhat.com> wrote:
>> 
>>> On Fri, Sep 09, 2011 at 09:33:33AM -0700, Roopa Prabhu wrote:

>>> 
>>> It's probably more interesting for a card without SRIOV support.
>>> 
>> If its an SRIOV card I am assuming people likely using PASSTHRU mode.
>> Non-SRIOV cards will use any of the non-PASSTHRU mode.
>> 
>> 
>>>> we will have to add filter lookup in macvlan
>>>> to filter pkts for each guest.
>>> 
>>> Any chance to enable hardware filters for that?
>>> 
>> NAFAIK. Am not sure how you would do it too. Its still a single device from
>> where the host receives traffic from.
>> 
>> Thanks,
>> Roopa
> 
> VMDQ cards might let you program mac addresses for individula rings.
> 
I tried to lookup more information on this. I dint find any concrete
information. I am not sure if individual rings show up as separate netdev.
Any more info on how a VMDQ nic is used with macvlan ?.

I came across this 
http://www.linux-kvm.org/wiki/images/6/6a/KvmForum2008$kdf2008_7.pdf

Thanks,
Roopa
 
 
