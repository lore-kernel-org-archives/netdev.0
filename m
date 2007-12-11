From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] netns: struct net content re-work
Date: Mon, 10 Dec 2007 20:12:06 -0800 (PST)
Message-ID: <20071210.201206.143407583.davem@davemloft.net>
References: <475D7849.3030206@fr.ibm.com>
	<475D7C56.9020402@sw.ru>
	<m1lk8127yg.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dev@sw.ru, dlezcano@fr.ibm.com, containers@lists.osdl.org,
	den@openvz.org, herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45081
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751998AbXLKEMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 23:12:07 -0500
In-Reply-To: <m1lk8127yg.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 10 Dec 2007 21:04:07 -0700

> Kirill Korotaev <dev@sw.ru> writes:
> 
> > Daniel Lezcano wrote:
> >> Denis V. Lunev wrote:
> >> Can you change this from unx to unix ?
> >
> > no, it won't compile. Guess why :)
> 
> Hmm.  It looks like it is a #define somewhere gcc?

It is a platform CPP pre-define for UNIX platforms.
