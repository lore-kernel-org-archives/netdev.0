From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: on the topic of alternate MAC addresses
Date: Thu, 25 Oct 2007 11:36:53 -0600
Message-ID: <m13avz5c5m.fsf@ebiederm.dsl.xmission.com>
References: <20071023.180534.59659315.davem@davemloft.net>
	<471EAD01.5030502@garzik.org>
	<20071023.202210.74747025.davem@davemloft.net>
	<m13avz6ujf.fsf@ebiederm.dsl.xmission.com> <4720CEE2.1010007@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:54920 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480AbXJYRhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 13:37:17 -0400
In-Reply-To: <4720CEE2.1010007@hp.com> (Rick Jones's message of "Thu, 25 Oct
	2007 10:14:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> writes:

> Eric W. Biederman wrote:
>> Duplicate mac addresses across interfaces on the same machine
>> should generally be a don't care.  Although there may some
>> cases we don't mind.
>
> What might the switches think of that?  Outside of the context of a
> link-aggregate I would think that could do some unhappy things when multiple
> interfaces are connected to the same broadcast domain.
>
> That the "all interfaces have one MAC" default behaviour on SPARC systems often
> ran into troubles is probably cautionary here.

Sure we don't want to duplicate mac addresses globally by default.

The case that is always wrong is duplicate mac addresses going
in and out the same interface, and skimming through the code
it looks like we already have the data structures necessary to
prevent duplicate use of unicast mac addresses already.

Eric
