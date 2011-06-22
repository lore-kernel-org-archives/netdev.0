From: Tim Gardner <tim.gardner@canonical.com>
Subject: Re: Reported regression against commit a05d2ad
Date: Wed, 22 Jun 2011 11:32:46 -0600
Message-ID: <4E02273E.2080000@canonical.com>
References: <20110621201528.GB2249@herton-IdeaPad-Y430> <m1oc1qnc46.fsf@fess.ebiederm.org>
Reply-To: tim.gardner@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>,
	lamont@canonical.com, sconklin@canonical.com,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:4438 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757427Ab1FVRc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 13:32:58 -0400
In-Reply-To: <m1oc1qnc46.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/21/2011 02:49 PM, Eric W. Biederman wrote:
<snip>
> I respectfully suggest that the bug is elsewhere perhaps a broken user
> space application out there that needs to be fixed, or you have a kernel
> memory stomp that removing patch a05d2ad happens to shift the memory
> layout to be harmful in a different way.
>

OK, I'm remembering how PF_UNIX Unix domain sockets are used, so I think 
your theory about a misbehaving user space application is more likely. 
However, I am a bit confused about how an application can attempt to 
receive before the socket is fully opened. Some kind of race condition 
with socketpair() ?

rtg
-- 
Tim Gardner tim.gardner@canonical.com
