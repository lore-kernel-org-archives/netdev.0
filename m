From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/8] Support unix domain sockets across namespaces
Date: Wed, 16 Jun 2010 16:32:59 -0700
Message-ID: <m1vd9isgd0.fsf@fess.ebiederm.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
	<20100616.151536.70195214.davem@davemloft.net>
	<20100616.161706.229750834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: serue@us.ibm.com, containers@lists.osdl.org,
	daniel.lezcano@free.fr, netdev@vger.kernel.org, xemul@parallels.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34074 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484Ab0FPXdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 19:33:09 -0400
In-Reply-To: <20100616.161706.229750834.davem@davemloft.net> (David Miller's message of "Wed\, 16 Jun 2010 16\:17\:06 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: David Miller <davem@davemloft.net>
> Date: Wed, 16 Jun 2010 15:15:36 -0700 (PDT)
>
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Sun, 13 Jun 2010 06:25:32 -0700
>> 
>>> This patchset takes a addressing all of the issues that crop up with
>>> unix domain sockets when the senders and receivers are in separate
>>> namespaces.
>>> 
>>> Without this patchset we can report the wrong pid and uid
>>> values in our unix domain credentials.
>>> 
>>> As a finally this patchset removes the now unnecessary restriction
>>> that we only allow unix domain sockets between processes in the
>>> same network namespace.
>> 
>> Looks good, all applied to net-next-2.6, thanks Eric.
>
> I had to add a module export of cred_to_ucread to fix the allmodconfig
> build since AF_UNIX makes a reference to it.

Doh!  Thank you for catching that.

My apologies for overlooking the allmodconfig case.

Eric

