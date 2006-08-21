From: Peter Bieringer <pb@bieringer.de>
Subject: Re: Bug in order of multiple IPv6 addresses per interface? Newest
 added one is preferred in difference to IPv4
Date: Mon, 21 Aug 2006 12:00:09 +0200
Message-ID: <44E98429.9030607@bieringer.de>
References: <20060821185610.07dce833.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>,
	usagi-users@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pog.aerasec.de ([195.226.187.54]:29317 "EHLO smtp4.aerasec.de")
	by vger.kernel.org with ESMTP id S1751831AbWHUKAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 06:00:21 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060821185610.07dce833.ipng@69706e6720323030352d30312d31340a.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Smith schrieb:
> Hi,
> 
> Sorry not to preserve the list/thread ID, I read the list via nntp/gmane, so please also CC' me directly for replies.
> 
>> # ip -6 addr show dev eth0  |grep -w inet6 |grep -w global
>     inet6 2001:db8:0:1::253/64 scope global   <- #2 !!!!
>     inet6 2001:db8:0:1::11/64 scope global    <- #1
> 
>> So the last added on is now the first in list. Also, it gets no
>> "secondary" flag and "ip" doesn't even support this flag.
> 
>> And the worse thing is that the first one in list (= last added one) is
>> now used as default for outgoing connections. Can be easily tested using
>> "ping6".
> 
> 
>> Is this a bug (I hope so) or a (undocumented?) feature?
> 
> Could it be because the new address as a newer and therefore longer
> preferred and valid lifetimes, and therefore becomes a more preferred
> IPv6 source address to use for new connections ? 

Hmm, both addresses have:
	valid_lft forever preferred_lft forever

	Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                       mailto:pb@bieringer.de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
OpenBC                    http://www.openbc.com/hp/Peter_Bieringer/
Personal invitation to OpenBC  http://www.openbc.com/go/invita/3889
