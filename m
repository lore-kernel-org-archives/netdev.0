From: David Ahern <dsahern@gmail.com>
Subject: Re: VRFs and the scalability of namespaces
Date: Mon, 29 Sep 2014 17:43:43 -0600
Message-ID: <5429EEAF.9030702@gmail.com>
References: <5425EAA6.7040302@gmail.com> <1411824598.2136890.172383085.705271DD@webmail.messagingengine.com> <54295971.2040402@gmail.com> <54298B66.8060807@candelatech.com> <CACP96tR_c3-nVEGhswm1qt1WGXPNzyXA61FCxPutCTPNomjy+g@mail.gmail.com> <54299019.3050604@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
	Sowmini Varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:45053 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbaI2Xnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 19:43:52 -0400
Received: by mail-pd0-f171.google.com with SMTP id ft15so2403984pdb.30
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 16:43:52 -0700 (PDT)
In-Reply-To: <54299019.3050604@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/29/14, 11:00 AM, Ben Greear wrote:
> On 09/29/2014 09:50 AM, Sowmini Varadhan wrote:
>> On Mon, Sep 29, 2014 at 12:40 PM, Ben Greear <greearb@candelatech.com> wrote:
>>> On 09/29/2014 06:06 AM, David Ahern wrote:
>>
>>>
>>> We have implemented support for at least most of this (excepting duplicate IPs)
>>> using routing tables, rules, and (optionally, xorp as the router).
>>>
>>
>> My undertanding of multiple routing-tables/rules was that they
>> are closer in semantics to switch/router ACLs than to VRFs, eg.,
>> one big difference is that an interface can belong to exactly one
>> VRF at a time, which is not mandated by multiple routing-tables/rules.
>>
>> Was I mistaken?
>
> You can effectively force an interface to belong to a particular virtual
> router (table).  It is not trivial to do, and possibly I have still not
> covered every possible case.  Some rules grow somewhat exponentially as
> interfaces are added to virtual routers (ie, preference 10 rules).

An interesting way of doing it; thanks for the reference point.

Fundamentally the design should be able to assign interfaces to a single 
VRF, support duplicate IP addresses on different interfaces in different 
VRFs and be able to scale to 10,000+ netdevices -- devices representing 
physical ports as well as logical interfaces built on top of them (e.g., 
sub-interfaces).

David
