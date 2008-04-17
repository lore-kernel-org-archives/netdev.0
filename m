From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: catch signed nla_len() retval in tcf_simp_init()
Date: Thu, 17 Apr 2008 15:10:38 +0200
Message-ID: <48074C4E.6060400@trash.net>
References: <4806C501.20300@tiscali.nl>	 <20080416.213712.78410382.davem@davemloft.net> <4806D847.2030806@trash.net> <1208437113.4420.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, 12o3l@tiscali.nl,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63121 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbYDQNKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 09:10:42 -0400
In-Reply-To: <1208437113.4420.34.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Thu, 2008-17-04 at 06:55 +0200, Patrick McHardy wrote:
> 
>> The change is also unnecessary because the attribute was
>> already validated and the length can not be less than zero.
> 
> Since act_simple is an academic example:
> I think that a better solution is to add TCA_DEF_DATA (which is a
> string) to the nla_policy. nla_policy is defined but at the moment it is
> not used in the call to nla_parse_nested() - might as well use it.

Basic validity checks are always performed. But I agree, better
to provide a good example.
