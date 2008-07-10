From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 10 Jul 2008 12:51:30 +0200
Message-ID: <200807101251.30712.thomas.jarosch@intra2net.com>
References: <200807101146.26034.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re01.intra2net.com ([82.165.28.202]:56445 "EHLO
	re01.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753050AbYGJKve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 06:51:34 -0400
In-Reply-To: <200807101146.26034.thomas.jarosch@intra2net.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> After upgrading to 2.6.25.10, the TCP connection still stalls.
>
> I temporarily disabled PMTU discovery, TCP window scaling, TCP SACK
> and manually forced the MTU to 1400 with no noticable effect.

We found a workaround by putting a linux-based AVM fritz!box router between 
kernel 2.6.25.10 and the mailserver, now the TCP connection works again,
though it gets NATed. Still can't make any sense out of this.

On another box which showed similar behaviour,
upgrading from 2.6.24.7 to 2.6.25.10 solved the issue.

Thomas

-- 
Address (better: trap) for people I really don't want to get mail from:
napoleon.dynamite@cactusamerica.com
