From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 9/15] BE NIC driver - Linux system abstraction files
Date: Thu, 15 May 2008 13:33:28 -0400
Message-ID: <482C73E8.6090208@garzik.org>
References: <20080515092638.a9ce4c89@mailhost.serverengines.com> <87mymrztse.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Subbu Seetharaman <subbus@serverengines.com>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38014 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750844AbYEORdd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 13:33:33 -0400
In-Reply-To: <87mymrztse.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> "Subbu Seetharaman" <subbus@serverengines.com> writes:
>> + */
>> +/*
>> + * system abstraction functions / macros for Linux
> 
> Sorry, pretty much this complete file has to go and the callers 
> be fixed to use the native Linux functions directly. Some of it
> was even wrong, like it's not legal to cast atomic_t like you did.
> 
> Also a lot of facilities you reimplement here exist already in Linux
> anyways under other names.

Quite agreed (speaking as net driver maintainer)

	Jeff




