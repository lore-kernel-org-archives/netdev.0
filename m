From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Query on usage of multicast as source IPv6 address
Date: Mon, 7 Nov 2011 13:11:01 -0800
Message-ID: <20111107131101.160dd491@nehalam.linuxnetplumber.net>
References: <20111107204550.GB2980@kumar.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kumar Sanghvi <divinekumar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46154 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750722Ab1KGVLF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 16:11:05 -0500
In-Reply-To: <20111107204550.GB2980@kumar.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Nov 2011 02:15:52 +0530
Kumar Sanghvi <divinekumar@gmail.com> wrote:

> However, what should be the behavior if a host receives a
> packet (probably from a malicious host with pktgen abilities)
> having a multicast address in source address field:
> 1) Should the receiving host discard the packet?
> 2) Should the receiving host dicard the packet, and send back
>    ICMP error?
> 3) Or should the receiving host send a response to the multicast
>    address?

Before the Internet was full of people sending malicious packets,
the standards encourage sending ICMP errors. Later RFC's discourage
sending ICMP's for many cases (See RFC 1812).

IMHO just drop packet making sure to increment appropriate statistic.
