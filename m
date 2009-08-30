From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] r8169: Reduce looping in the interrupt handler.
Date: Sun, 30 Aug 2009 13:53:22 -0700
Message-ID: <m17hwl2fct.fsf@fess.ebiederm.org>
References: <1251294974.14241.9.camel@obelisk.thedillows.org>
	<1251295175.14241.11.camel@obelisk.thedillows.org>
	<m11vmy737x.fsf@fess.ebiederm.org>
	<20090826213024.GA20428@electric-eye.fr.zoreil.com>
	<m1hbvu45jq.fsf@fess.ebiederm.org>
	<20090827052423.GA1709@electric-eye.fr.zoreil.com>
	<m1ocq1ke9u.fsf@fess.ebiederm.org>
	<20090827232024.GA30119@electric-eye.fr.zoreil.com>
	<m1d46gka9e.fsf@fess.ebiederm.org>
	<1251422978.21865.2.camel@obelisk.thedillows.org>
	<20090830203735.GA24912@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Dillow <dave@thedillows.org>,
	Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Rui Santos <rsantos@grupopie.com>,
	Michael B??ker <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54012 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008AbZH3Uxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 16:53:30 -0400
In-Reply-To: <20090830203735.GA24912@electric-eye.fr.zoreil.com> (Francois Romieu's message of "Sun\, 30 Aug 2009 22\:37\:35 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> writes:

> David Dillow <dave@thedillows.org> :
> [...]
>> It'll be this weekend, but I can see cases where it can lock my chip up
>> -- they should be rare, but then I thought your case would be extremely
>> rare...
>
> I don't get it.
>
> Can you elaborate the relevant cases or give some sample scenarios for
> them ?

I think David is referring to the fact that in the NAPI loop there is
nothing that acks everything.

Eric
