From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bugme-new] [Bug 14837] New: gretap does not fragment IP
 packets
Date: Fri, 18 Dec 2009 15:47:00 -0800
Message-ID: <20091218154700.623f6779@nehalam>
References: <bug-14837-10286@http.bugzilla.kernel.org/>
	<20091218153209.45042a58.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, benoit.papillault@free.fr,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52514 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753244AbZLRXrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2009 18:47:22 -0500
In-Reply-To: <20091218153209.45042a58.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Dec 2009 15:32:09 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> > 
> > The expected behavior would be that the encapsulated packet be fragmented. The
> > observed behavior is that any encapsulated packets over 1500 bytes are simply
> > dropped and an ICMP "fragmentation needed" message is sent to ... who knows.
> > 
> > My feeling is that DF bit is not playing nice here.
> >   

TCP uses DF bit to do path mtu discovery.  If your firewall et all, doesn't
do ICMP correctly, then this is the classic TCP path MTU discovery ICMP
blackhole problem. 

http://www.ietf.org/rfc/rfc2923.txt
