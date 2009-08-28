From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] r8169: Reduce looping in the interrupt handler.
Date: Thu, 27 Aug 2009 18:17:01 -0700
Message-ID: <m1d46gka9e.fsf@fess.ebiederm.org>
References: <m1k50r8u4p.fsf@fess.ebiederm.org>
	<20090825221903.GA13630@electric-eye.fr.zoreil.com>
	<m1iqgbknun.fsf_-_@fess.ebiederm.org>
	<1251294974.14241.9.camel@obelisk.thedillows.org>
	<1251295175.14241.11.camel@obelisk.thedillows.org>
	<m11vmy737x.fsf@fess.ebiederm.org>
	<20090826213024.GA20428@electric-eye.fr.zoreil.com>
	<m1hbvu45jq.fsf@fess.ebiederm.org>
	<20090827052423.GA1709@electric-eye.fr.zoreil.com>
	<m1ocq1ke9u.fsf@fess.ebiederm.org>
	<20090827232024.GA30119@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Dillow <dave@thedillows.org>,
	Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Rui Santos <rsantos@grupopie.com>,
	Michael B??ker <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751128AbZH1BRK@vger.kernel.org>
In-Reply-To: <20090827232024.GA30119@electric-eye.fr.zoreil.com> (Francois Romieu's message of "Fri\, 28 Aug 2009 01\:20\:24 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> writes:

> Eric W. Biederman <ebiederm@xmission.com> :
> [...]
>> Sounds good.
>
> Gah, I was not able to test it with a decent packet load. Patch below against
> the current tree:

This kills the loop which was my concern.

I will double check it works on my configuration.
Then we have the question of does it work for those folks who have cards
where the msi appeared to get lost.

David any chance you can test this patch?

Eric
