From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [patch iproute2] ipaddress: add a black line for each device to
 make the output more readable
Date: Tue, 12 Nov 2013 10:09:44 +0800
Message-ID: <20131112020944.GC1258@localhost.localdomain>
References: <1384182210-8901-1-git-send-email-liuhangbin@gmail.com>
 <20131111173100.108e9026@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:49917 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab3KLCJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 21:09:50 -0500
Received: by mail-pb0-f51.google.com with SMTP id xa7so6051392pbc.24
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 18:09:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131111173100.108e9026@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 05:31:00PM +0100, Jiri Benc wrote:
> On Mon, 11 Nov 2013 23:03:30 +0800, Hangbin Liu wrote:
> > When we have multi links, the output huddled together and make it hard to read.
> > Let's use the old ifconfig output style.
> 
> No. You can't break others' scripts like that.

Hi Jiri,

Thanks for you reminding.

Although I think a blank line won't have much influence for most of strong
scripts, it MAY break some. But the output will be more readable. I think that
worth it.
> 
> bash$ function ip { /sbin/ip "$@" | sed '2,$s/^[0-9]*:/\n&/' ; }

Yes, this function works great. But for administrators who have lots of systems
and NICs, it's hard to add the function/alias on each system. And the output
of ifconfig, which is still used by lots of admins, looks clearly. So why
don't we also use it?

-- 

Thanks & Best Regards
Hangbin Liu <liuhangbin@gmail.com>
