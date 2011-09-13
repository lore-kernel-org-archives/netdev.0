From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: bridge should flood non-IPv4-multicast ethernet frames
Date: Tue, 13 Sep 2011 14:14:03 -0700
Message-ID: <20110913141403.3e66e032@nehalam.linuxnetplumber.net>
References: <20110913200027.GQ28007@angus.ind.WPI.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chuck Anderson <cra@WPI.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44570 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756122Ab1IMVOF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Sep 2011 17:14:05 -0400
In-Reply-To: <20110913200027.GQ28007@angus.ind.WPI.EDU>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Sep 2011 16:00:27 -0400
Chuck Anderson <cra@WPI.EDU> wrote:

> 2. Check that the Ethertype is 0x800 (IPv4), and if it is not, always
> flood the frame so we don't break non-IPv6-multicast frames being
> bridged.

Doing something based on Ether type is the correct solution.
It should handle ipv4 and ipv6 snooping and flood all other types.
