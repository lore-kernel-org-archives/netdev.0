From: David Miller <davem@davemloft.net>
Subject: Re: [X25]: Avoid divides and sparse warnings
Date: Sun, 13 Jan 2008 22:29:07 -0800 (PST)
Message-ID: <20080113.222907.152771528.davem@davemloft.net>
References: <4789E8DD.2020901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48390
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752105AbYANG3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 01:29:07 -0500
In-Reply-To: <4789E8DD.2020901@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sun, 13 Jan 2008 11:33:01 +0100

>    CHECK   net/x25/af_x25.c
> net/x25/af_x25.c:117:46: warning: expensive signed divide
>    CHECK   net/x25/x25_facilities.c
> net/x25/x25_facilities.c:209:30: warning: expensive signed divide
>    CHECK   net/x25/x25_in.c
> net/x25/x25_in.c:250:26: warning: expensive signed divide
>    CHECK   net/x25/x25_proc.c
> net/x25/x25_proc.c:48:11: warning: context imbalance in 'x25_seq_route_start' 
> - wrong count at exit
> net/x25/x25_proc.c:72:13: warning: context imbalance in 'x25_seq_route_stop' - 
> unexpected unlock
> net/x25/x25_proc.c:112:11: warning: context imbalance in 
> 'x25_seq_socket_start' - wrong count at exit
> net/x25/x25_proc.c:129:13: warning: context imbalance in 'x25_seq_socket_stop' 
> - unexpected unlock
> net/x25/x25_proc.c:190:11: warning: context imbalance in 
> 'x25_seq_forward_start' - wrong count at exit
> net/x25/x25_proc.c:215:13: warning: context imbalance in 
> 'x25_seq_forward_stop' - unexpected unlock
>    CHECK   net/x25/x25_subr.c
> net/x25/x25_subr.c:362:57: warning: expensive signed divide
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.

We might just want to make sk_rcvbuf et al. unsigned, it
crops up a lot and I can't see any valid reason for it
to be negative or for uses of it to matter with other
signed values.

Or did we discuss that to death already? :-)
