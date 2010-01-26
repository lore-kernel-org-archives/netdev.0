From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Deadlock in IPv6 code while garbage collection on the rwlock
	protecting the routing tree.
Date: Tue, 26 Jan 2010 10:35:24 +0000
Message-ID: <20100126103524.GB7780@ff.dom.local>
References: <20100123.022210.56302976.davem@davemloft.net> <20100126094817.GA7780@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, djohnson@starentnetworks.com,
	sakkiped@starentnetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:43537 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932107Ab0AZKfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 05:35:30 -0500
Received: by fxm20 with SMTP id 20so176513fxm.21
        for <netdev@vger.kernel.org>; Tue, 26 Jan 2010 02:35:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100126094817.GA7780@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 26, 2010 at 09:48:17AM +0000, Jarek Poplawski wrote:
> On 23-01-2010 11:22, David Miller wrote:
> > This is all well and good, but meanwhile someone does need to
> > fix the deadlock originally reported here :-)
> 
> I hope I miss something ;-) but I can't see this deadlock; the
> write_lock_bh(&table->tb6_lock) is taken from a timer in this case,
> not from the thread holding read_lock_bh(&table->tb6_lock).

I missed again! Yes, I can see this deadlock now.

Sorry,
Jarek P.
