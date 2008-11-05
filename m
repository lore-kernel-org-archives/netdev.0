From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: IP-less bridge as a martian source
Date: Wed, 05 Nov 2008 12:26:06 +0100
Message-ID: <874p2m76sx.fsf@tac.ki.iif.hu>
References: <87tzb6nodj.fsf@tac.ki.iif.hu> <87wsg0wu78.fsf@tac.ki.iif.hu>
	<48FF614C.7020507@gmail.com> <48FF7AA3.50408@gmail.com>
	<87y707mjbi.fsf@tac.ki.iif.hu> <20081031084124.GA4364@ff.dom.local>
	<877i7novar.fsf@szonett.ki.iif.hu>
	<20081105094303.GA5378@ff.dom.local> <87prla79d6.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:38595 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754492AbYKEL0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 06:26:10 -0500
In-Reply-To: <87prla79d6.fsf@tac.ki.iif.hu> (Ferenc Wagner's message of "Wed,
	05 Nov 2008 11:30:45 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ferenc Wagner <wferi@niif.hu> writes:

> Jarek Poplawski <jarkao2@gmail.com> writes:
>
>> On Sun, Nov 02, 2008 at 12:55:56AM +0100, Ferenc Wagner wrote:
>> 
>>> If I ping -b 255.255.255.255 on a virtual machine with IP
>>> 193.225.14.155, whose virtual interface is a port of br891:
>>> 
>>> martian source 255.255.255.255 from 193.225.14.155, on dev br891

May be of interest, but on the other host (which currently does not
run the virtual machine running the above ping command, so the same
bridge is present but without the virtual interfaces), logged an extra
__ratelimit message preceeding the martian:

[288953.880497] __ratelimit: 102 messages suppressed
[288953.880585] martian source 255.255.255.255 from 193.225.14.155, on dev br891
[288953.880640] ll header: ff:ff:ff:ff:ff:ff:00:16:3e:01:00:00:08:00

If I ping again, no further __ratelimits emerge, and tcpdump shows a
single ICMP packet, the echo request.
-- 
Regards,
Feri.
