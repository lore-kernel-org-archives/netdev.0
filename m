From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: REGRESSION: On 2.6.32-rc5 the firmware hangs, and the nic is unusable.
Date: Wed, 04 Nov 2009 13:43:17 -0800
Message-ID: <m1skcux8y2.fsf@fess.ebiederm.org>
References: <m1tyxaagal.fsf@fess.ebiederm.org> <4AF1D2C6.20002@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>
To: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45192 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758269AbZKDVnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:43:17 -0500
In-Reply-To: <4AF1D2C6.20002@qlogic.com> (Dhananjay Phadke's message of "Wed\, 4 Nov 2009 11\:15\:18 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke <dhananjay.phadke@qlogic.com> writes:

> Eric W. Biederman wrote:
>> On 2.6.31.5 I get:
>> ethtool -i eth0
>> driver: netxen_nic
>> version: 4.0.30
>> firmware-version: 4.0.305
>> bus-info: 0000:06:00.0
>>
>
> Agree, 2.6.31 window missed bonding (mac addr setup) fixes.
>
>> And everything works except bonding.
>>
>> On 2.6.32-rc5 I dhcp I get an IP
>> there is a sanity test ping.
>
>>
>> Then the driver reports a firmware hang and
>> the interface goes down and I am dead in the water.
>>
>
>> I'm a bit frustrated with this as it seems with each kernel release
>> the driver gets a little bit less usable.
>>
>> Have I given you enough information to track this down?
>
> This can be fixed in next rc patch of 2.6.32, if I get enough info to debug.
>
> Could you provide full dmesg, so that I can see what's going on around firmware
> hang message? Also provide your test details (bonding / whatever configured).

I will dig up that dmesg in a bit.  Working on a machine when the network is
down is a pain.

There was no bonding configured.  Essentially just:
ifup eth0 finally get a dhcp response firmware hangs..

Eric
