From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Thu, 29 May 2008 15:43:15 +0200
Message-ID: <20080529134315.GA8176@elte.hu>
References: <20080526115628.GA31316@elte.hu> <20080529084524.GA24892@elte.hu> <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi> <20080529112257.GA18130@elte.hu> <20080529130535.GA10244@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:33900 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752135AbYE2Nnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 09:43:40 -0400
Content-Disposition: inline
In-Reply-To: <20080529130535.GA10244@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> Hi.
> 
> On Thu, May 29, 2008 at 01:22:57PM +0200, Ingo Molnar (mingo@elte.hu) wrote:
> > titan:~/tip> netstat -nt
> > Active Internet connections (w/o servers)
> > Proto Recv-Q Send-Q Local Address               Foreign Address             
> > State
> > tcp        0      0 10.0.1.14:22                10.0.1.16:58062  ESTABLISHED
> > tcp        0      0 10.0.1.14:22                10.0.1.16:60109  ESTABLISHED
> > tcp        0  86368 10.0.1.14:43914             10.0.1.16:3632   ESTABLISHED
> 
> Are namespaces enabled? It is pretty non-trivial to make established 
> socket without process from userspace :)

they are enabled in this particular kernel config, but there were a 
couple of other failures where they were not enabled.

	Ingo
