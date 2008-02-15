From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Make sure sockets implement splice_read
Date: Fri, 15 Feb 2008 17:46:53 +0100
Message-ID: <p73bq6iyxoi.fsf@bingen.suse.de>
References: <200802141853.35016.rdenis@simphalempin.com>
	<20080215.023601.219994317.davem@davemloft.net>
	<p73k5l6yygc.fsf@bingen.suse.de>
	<200802151840.16824.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:37745 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758042AbYBOQq5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 11:46:57 -0500
In-Reply-To: <200802151840.16824.rdenis@simphalempin.com>
 (=?iso-8859-1?Q?=22R=E9mi?= Denis-Courmont"'s message of "Fri\, 15 Feb 2008
 18\:40\:16 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=E9mi Denis-Courmont <rdenis@simphalempin.com> writes:

> Le Friday 15 February 2008 18:30:11 Andi Kleen, vous avez =E9crit=A0:
>> David Miller <davem@davemloft.net> writes:
>> > From: R=E9mi_Denis-Courmont <rdenis@simphalempin.com>
>> > Date: Thu, 14 Feb 2008 18:53:34 +0200
>> >
>> >> Fixes a segmentation fault when trying to splice from a non-TCP s=
ocket.
>> >>
>> >> Signed-off-by: R=E9mi Denis-Courmont <rdenis@simphalempin.com>
>> >
>> > Applied, thank you.
>>
>> That's also a stable candidate, isn't it?
>
> Should go to 2.6.25-rc2, but the offending code is not in any stable =
release.

You're right. I misinterpreted git describe output for this one. Sorry.

-Andi
