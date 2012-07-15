From: "Piotr Sawuk" <a9702387@unet.univie.ac.at>
Subject: Re: resurrecting tcphealth
Date: Sun, 15 Jul 2012 11:17:53 +0200
Message-ID: <3e426bd471b8a54bfa5320f05e88e635.squirrel@webmail.univie.ac.at>
References: <dee325378a2d3b7792da9640fc14905f.squirrel@webmail.univie.ac.at>
    <20120714144800.7f8c97f6@nehalam.linuxnetplumber.net>
    <b93cddfd0a19158ec59823140d1e2075.squirrel@webmail.univie.ac.at>
    <1342336597.3265.10617.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from grace.univie.ac.at ([131.130.3.115]:45120 "EHLO
	grace.univie.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730Ab2GOJR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 05:17:56 -0400
In-Reply-To: <1342336597.3265.10617.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On So, 15.07.2012, 09:16, Eric Dumazet wrote:
> On Sun, 2012-07-15 at 01:43 +0200, Piotr Sawuk wrote:
>
>> oh, and again I recommend the really short although outdated thesis
>>
>> [1] https://sacerdoti.org/tcphealth/tcphealth-paper.pdf
>
> A thesis saying SACK are not useful is highly suspect.
>
> Instead of finding why they behave not so good and fix the bugs, just
> say "SACK addition to TCP is not critical"
the actual quotation is "We also found that the number of unnecessary
duplicate packets were quite small potentially indicating that the SACK
addition to TCP is not critical."
>
> Really ?

no, not really. he he actually said that SACK has been made mostly obsolete
by "Linux 2.2 implements fast retransmits for up to two packet gaps, thus
reducing the need for course grained timeouts due to the lack of SACK." and
he was a bit more careful and admitted that further tests with tcphealth are
needed to check if SACK really makes that big a difference. he admitted "It
could be that SACK's advantage lies in other areas such as very large
downloads or when using slow and unreliable network links." all these things
could be checked again nowadays, with larger files available and wlan-users
and higher traffic -- just find something without SACK...
