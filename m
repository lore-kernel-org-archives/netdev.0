From: Tony Zelenoff <antonz@parallels.com>
Subject: Re: [PATCH 0/9] atl1: add napi to Atheros L1 NIC
Date: Mon, 16 Apr 2012 11:22:43 +0400
Message-ID: <4F8BC8C3.6020102@parallels.com>
References: <1334333394-38404-1-git-send-email-antonz@parallels.com> <20120415.130346.1822341707659142562.davem@davemloft.net> <20120415.132805.143754486571031578.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jcliburn@gmail.com" <jcliburn@gmail.com>,
	"csnook@redhat.com" <csnook@redhat.com>,
	Konstantin Khorenko <khorenko@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:36361 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693Ab2DPHWF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 03:22:05 -0400
In-Reply-To: <20120415.132805.143754486571031578.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

4/15/12 9:28 PM, David Miller =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=
:
> From: David Miller<davem@davemloft.net>
> Date: Sun, 15 Apr 2012 13:03:46 -0400 (EDT)
>
>> From: Tony Zelenoff<antonz@parallels.com>
>> Date: Fri, 13 Apr 2012 20:09:45 +0400
>>
>>> Added NAPI interface to the driver of Atheros L1 NIC.
>>> RX speed reported by iperf in TCP mode (with and without -N
>>> switch) improved by ~7 Mbps. In UDP mode the speed up is
>>> improved by ~4 Mbps.
>>> Also hard RX/TX rings processing with memory allocation in
>>> interrupt handlers is not very good idea. So, fixed this.
>>>
>>> Note: thouse patches must be applied after patch, that fix
>>> kernel panic in this driver.
>>> Its subject is: "atl1: fix kernel panic in case of DMA errors"
>>
>> Unfortunately this is bullshit.  These patches actually depend upon
>> that bug fix not being applied.  Look at the patches, they reference
>> and use the reset workqueue the bug fix removed.
Sorry, for long time to reply, unfortunately i had no internet access a=
t=20
this weekend.

> My bad, I thought I had merged the net tree into net-next before
> processing your patches but I didn't.
>
> I just fixed this all up in the net-next tree, please double
> check my work.
In atl1.h there is tx_timeout_task member of atl1_adapter remained. It=20
was removed from this structure when kernel panic was fixed.
The patch will be soon.

Also, i'm interested in what to do with Chris Nook address in contacts=20
list. Reason - mailer respond that this address is not valid anymore.=20
Should i remove him from contacts or leave?

Mailer response:

   csnook@redhat.com
     SMTP error from remote mail server after RCPT TO:<csnook@redhat.co=
m>:
     host mx1.redhat.com [209.132.183.28]: 550 5.2.1=20
<csnook@redhat.com>... Mailbox disabled for this recipient
