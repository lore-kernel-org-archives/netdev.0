From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net device
 sysfs entries
Date: Thu, 23 Oct 2008 13:56:33 +0200
Message-ID: <49006671.3010804@bull.net>
References: <20081022152144.351965414@theryb.frec.bull.fr> <m1d4hso0ym.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dave Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Serge Hallyn <serue@us.ibm.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:58586 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958AbYJWMAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 08:00:32 -0400
In-Reply-To: <m1d4hso0ym.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Benjamin Thery <benjamin.thery@bull.net> writes:
> 
>> Support for network namespaces in mainline is pretty complete for
>> some time now, but there is still this issue with sysfs that prevents 
>> more people to use it easily.
> 
> Ben your patchset is completely inappropriate.
> 
> Temporarily adding elements to the ABI that we intend to remove
> is not a proper solution to this problem.

In fact, I feared that would be an issue before I sent the patches.
Thanks for confirming this.

But, as this alternative was discussed a bit after Al's comments on your
last patches, I had to give it a try and code a proof-of-concept.

Benjamin

> 
> That user space visible ida you add is a namespace identifier that breaks
> nested containers and migration.  It is very very very wrong.
> 
> Eric
> 
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
