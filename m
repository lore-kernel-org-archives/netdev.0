From: Rick Jones <rick.jones2@hp.com>
Subject: Re: on the topic of alternate MAC addresses
Date: Thu, 25 Oct 2007 10:14:10 -0700
Message-ID: <4720CEE2.1010007@hp.com>
References: <20071023.180534.59659315.davem@davemloft.net>	<471EAD01.5030502@garzik.org>	<20071023.202210.74747025.davem@davemloft.net> <m13avz6ujf.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:51954 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753674AbXJYRON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 13:14:13 -0400
In-Reply-To: <m13avz6ujf.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Duplicate mac addresses across interfaces on the same machine
> should generally be a don't care.  Although there may some
> cases we don't mind.

What might the switches think of that?  Outside of the context of a 
link-aggregate I would think that could do some unhappy things when multiple 
interfaces are connected to the same broadcast domain.

That the "all interfaces have one MAC" default behaviour on SPARC systems often 
ran into troubles is probably cautionary here.

rick jones
