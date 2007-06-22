From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET 00/02]: Secondary unicast address support
Date: Fri, 22 Jun 2007 03:56:09 +0200
Message-ID: <467B2C39.1040208@trash.net>
References: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>	<m13b0lf7mr.fsf@ebiederm.dsl.xmission.com>	<467ACDE1.7070907@trash.net> <m1sl8ldp6u.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, jeff@garzik.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51532 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbXFVB4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 21:56:36 -0400
In-Reply-To: <m1sl8ldp6u.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> For the macvlan hash you just use an upper byte.  Is that just a
> simple starting place, or do we not need a more complex hash.
>   

That gave me an idea, since the default addresses are random
anyway I'm now using an incrementing counter for the upper byte.


