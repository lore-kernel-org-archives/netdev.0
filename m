From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] igb: panic at boot time with latest Linus tree
Date: Tue, 31 Jul 2012 10:42:54 +0200
Message-ID: <1343724174.21269.168.camel@edumazet-glaptop>
References: <1343715255.21269.47.camel@edumazet-glaptop>
	 <1343715971.2230.4.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38813 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754826Ab2GaIm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 04:42:58 -0400
Received: by bkwj10 with SMTP id j10so3163956bkw.19
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2012 01:42:57 -0700 (PDT)
In-Reply-To: <1343715971.2230.4.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-30 at 23:26 -0700, Jeff Kirsher wrote:
> On Tue, 2012-07-31 at 08:14 +0200, Eric Dumazet wrote:
> > For information, I get this each time I boot on latest Linus tree :
> > 
> > RTNL is left locked, so machine unusable.
> > 
> > No problem with David net tree, so thats a bit strange...
> > 
> > Not sure I'll have time to investigate today
> > (And tomorrow I am off for the day)
> > 
> > 
> > 
> 
> I have an igb patch current in test to fix a panic in igb.  Here is the
> patch:
> 



Ah sorry for the false alarm, it appears I had igb module in a out of date initrd file (coming from my net tree)
