From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] r8169: Reduce looping in the interrupt handler.
Date: Wed, 26 Aug 2009 22:38:05 -0700
Message-ID: <m1ocq1ke9u.fsf@fess.ebiederm.org>
References: <m1prajabk8.fsf@fess.ebiederm.org>
	<1251232848.9607.15.camel@lap75545.ornl.gov>
	<m1k50r8u4p.fsf@fess.ebiederm.org>
	<20090825221903.GA13630@electric-eye.fr.zoreil.com>
	<m1iqgbknun.fsf_-_@fess.ebiederm.org>
	<1251294974.14241.9.camel@obelisk.thedillows.org>
	<1251295175.14241.11.camel@obelisk.thedillows.org>
	<m11vmy737x.fsf@fess.ebiederm.org>
	<20090826213024.GA20428@electric-eye.fr.zoreil.com>
	<m1hbvu45jq.fsf@fess.ebiederm.org>
	<20090827052423.GA1709@electric-eye.fr.zoreil.com>
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
Received: from out01.mta.xmission.com ([166.70.13.231]:42290 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbZH0FiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 01:38:13 -0400
In-Reply-To: <20090827052423.GA1709@electric-eye.fr.zoreil.com> (Francois Romieu's message of "Thu\, 27 Aug 2009 07\:24\:23 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> writes:

> [...]
>> Right now I really don't have much more test bandwidth.  So I tried
>> for something simple that would address my problem without
>> fundamentally changing the already tested logic.
>
> Fair enough.
>
> [...]
>> Perhaps we should unconditionally ack everything after changing the 
>> interrupt mask  ? If that would prevent races it sounds like a simple
>> fix.
>
> I should be able to implement something right this evening, please hold on.

Sounds good.

Eric
