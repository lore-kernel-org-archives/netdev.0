From: Kumar Sanghvi <divinekumar@gmail.com>
Subject: Re: Query on usage of multicast as source IPv6 address
Date: Tue, 8 Nov 2011 02:50:08 +0530
Message-ID: <20111107211940.GA3198@kumar>
References: <20111107204550.GB2980@kumar.asicdesigners.com>
 <20111107131101.160dd491@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:40110 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab1KGVUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 16:20:18 -0500
Received: by qao25 with SMTP id 25so1048795qao.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 13:20:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20111107131101.160dd491@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Mon, Nov 07, 2011 at 13:11:01 -0800, Stephen Hemminger wrote:
> On Tue, 8 Nov 2011 02:15:52 +0530
> Kumar Sanghvi <divinekumar@gmail.com> wrote:
> 
> > However, what should be the behavior if a host receives a
> > packet (probably from a malicious host with pktgen abilities)
> > having a multicast address in source address field:
> > 1) Should the receiving host discard the packet?
> > 2) Should the receiving host dicard the packet, and send back
> >    ICMP error?
> > 3) Or should the receiving host send a response to the multicast
> >    address?
> 
> Before the Internet was full of people sending malicious packets,
> the standards encourage sending ICMP errors. Later RFC's discourage
> sending ICMP's for many cases (See RFC 1812).
> 
> IMHO just drop packet making sure to increment appropriate statistic.

Thank you for your reply.
However, I could not understand why Linux (tested on 3.1 kernel) sends
a response on multicast address for such malicious packets (see
tcpdump output in my original mail) ?

Was there some specific reason that we decided to send a response to
multicast address in Linux? Or is there some knob (e.g. sysfs/proc entry)
available using which we can modify the default Linux behavior ?

Thanks,
Kumar.
