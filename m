From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: net-2.6.20 rebased
Date: Thu, 16 Nov 2006 12:04:23 +0000
Message-ID: <20061116120423.GF29920@ftp.linux.org.uk>
References: <20061116.055840.78704296.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:10728 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1161901AbWKPMEX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 07:04:23 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061116.055840.78704296.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 16, 2006 at 05:58:40AM -0500, David Miller wrote:
> 
> I just rebased net-2.6.20 at:
> 
>   master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.20.git
> 
> Al Viro has been going crazy with endianness and checksum type
> sparse annotations, which brings the patch count up to 171.
> Not bad for how long the net-2.6.20 tree has been open :-)

FWIW, with these patches in we have net/ nearly endian-clean.  Two
major exceptions are ieee80211 and sctp.  I think I've got more or
less sane way to deal with the latter, it won't be fun (and yes,
that's the queue I'm currently getting into shape).  A bunch of
genuine bugs in there, too, especially when it comes to sctp+ipv6...
