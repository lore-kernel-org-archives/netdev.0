From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: [BUG] problems with "ip xfrm" on 32-bit userspace with 64-bit
 kernel
Date: Thu, 21 Oct 2010 09:05:46 -0600
Message-ID: <4CC056CA.9060903@genband.com>
References: <4CBF78B6.90002@genband.com> <20101021075056.GE15247@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og108.obsmtp.com ([64.18.2.169]:34502 "EHLO
	exprod7og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758357Ab0JUPF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:05:59 -0400
In-Reply-To: <20101021075056.GE15247@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2010 01:50 AM, Florian Westphal wrote:
> Chris Friesen <chris.friesen@genband.com> wrote:
>> We've run into a 32/64 compatibility problem with iproute2.  The "ip
>> xfrm monitor acquire" command doesn't work properly due to struct size
>> mismatches between kernel and userspace.
> 
> Yes.  See archives for 'xfrm: add x86 CONFIG_COMPAT support'
> (http://marc.info/?t=127050655600003&r=1&w=2)
> 
> for a discussion on why the patch set to fix this was rejected.

Interesting discussion.  Kind of sucks for people trying to use it though.

How do distros resolve this?  Do they build iproute2 as a 64-bit package
or something?

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
