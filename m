From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: rt_check_expire() can take a long time, add a
 cond_resched()
Date: Sat, 17 Nov 2007 16:03:16 -0800 (PST)
Message-ID: <20071117.160316.162501140.davem@davemloft.net>
References: <473D18A5.2090309@cosmosbay.com>
	<20071115215938.44233733@laptopd505.fenrus.org>
	<p73k5ohav4n.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arjan@infradead.org, dada1@cosmosbay.com,
	linux-kernel@vger.kernel.org, netdev@vget.kernel.org
To: andi@firstfloor.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756591AbXKRADc@vger.kernel.org>
In-Reply-To: <p73k5ohav4n.fsf@bingen.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Sat, 17 Nov 2007 13:56:08 +0100

> Arjan van de Ven <arjan@infradead.org> writes:
> >> > 
> >> > Its not that cheap. The ChangeLog included my own numbers, on a
> >> > Pentium M machine. (i686, 1.6 GHz, 1.5 GB ram)
> >> > 
> >> > Without "if (need_resched())" (so calling need_resched() X.XXX.XXX 
> >> > times), each run takes 88ms
> >> > 
> >> > With the extra check (and *much* less function calls), each run
> >> > takes 25ms
> 
> ms?!? The numbers sound wrong. Wrong unit? 

Read what Eric is saying.  He is saying "any entire run" purging
the routing cache takes that long, not just one call.
