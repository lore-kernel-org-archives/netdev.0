From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 0/2] net: usb: cdc_ncm: Adding support for two new Dell devices
Date: Thu, 17 Dec 2015 13:21:31 +0100
Message-ID: <87fuz15kqc.fsf@nemi.mork.no>
References: <1450258765-11215-1-git-send-email-dnlplm@gmail.com>
	<1450285954.23793.15.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniele Palmas <dnlplm@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55142 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756172AbbLQMVu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 07:21:50 -0500
In-Reply-To: <1450285954.23793.15.camel@redhat.com> (Dan Williams's message of
	"Wed, 16 Dec 2015 11:12:34 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams <dcbw@redhat.com> writes:
> On Wed, 2015-12-16 at 10:39 +0100, Daniele Palmas wrote:
>> This patch series add support in the cdc_ncm driver for two devices
>> based on the same platform, that are different only for carrier
>> customization.
>>=20
>> The devices do not have ARP capabilities.
>>=20
>> Daniele Palmas (2):
>>   net: usb: cdc_ncm: Adding Dell DW5812 LTE Verizon Mobile Broadband
>>     Card
>>   net: usb: cdc_ncm: Adding Dell DW5813 LTE AT&T Mobile Broadband
>> Card
>
> Quite interesting; Google knows nothing about these devices that I ca=
n
> find.  What platform are these based on?

There are a number of launchpad bugs reported for these devices.  Don't
know why they chose that channel..  This one:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1520147
shows that it is an Intel/Infineon based design.

BTW, DeWalt seems to own these device names :)


Bj=C3=B8rn
