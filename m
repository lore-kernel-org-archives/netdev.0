From: Chris Bredesen <cbredesen@redhat.com>
Subject: Debugging TCP: Treason Uncloaked
Date: Wed, 07 May 2008 22:29:52 -0400
Message-ID: <482265A0.8040105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44547 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761504AbYEHCaG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 22:30:06 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m482U50f015522
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 22:30:05 -0400
Received: from file.rdu.redhat.com (file.rdu.redhat.com [10.11.255.147])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m482TrcT005836
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 22:30:05 -0400
Received: from [10.11.15.32] (vpn-15-32.rdu.redhat.com [10.11.15.32])
	by file.rdu.redhat.com (8.13.1/8.13.1) with ESMTP id m482Tr01007833
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 22:29:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

As per below thread, I'm forwarding to this list/alias.  tcpdump output
is attached to the forum post.

Thanks!

-------- Original Message --------
Subject: Re: F8 Treason Uncloaked
Date: Tue, 6 May 2008 20:00:51 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Organization: Red Hat UK Cyf., Amberley Place, 107-111 Peascod Street,
Windsor, Berkshire, SL4 1TE, Y Deyrnas Gyfunol. Cofrestrwyd yng Nghymru
a Lloegr o'r rhif cofrestru 3798903
To: For users of Fedora <fedora-list@redhat.com>
CC: cbredesen@redhat.com
References: <4820A59F.7010005@redhat.com>

On Tue, 06 May 2008 14:38:23 -0400
Chris Bredesen <cbredesen@redhat.com> wrote:

> Hello list,
> 
> I'm trying to get this issue out to a wider audience.  I posted it on 
> the forum but got no responses:
> 
> http://www.fedoraforum.org/forum/showthread.php?t=186331
> 
> Sorry to cross post, but I'm not sure where else to turn...

netdev@linux.kernel.org

but the TCP messages really indicate either a Linux bug or that the NAS
isn't talking proper TCP. Trying turning off window scaling was a good
test but beyond that tcpdump data will be needed.

Alan

