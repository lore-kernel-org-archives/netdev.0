From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Please revert disallowing zero listen queues
Date: Tue, 06 Mar 2007 10:45:11 -0800 (PST)
Message-ID: <20070306.104511.27784000.davem@davemloft.net>
References: <200703061332.09677@strip-the-willow>
	<20070306.103706.68156515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weid@np.css.fujitsu.com
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45060
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S966005AbXCFSpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 13:45:14 -0500
In-Reply-To: <20070306.103706.68156515.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 06 Mar 2007 10:37:06 -0800 (PST)

> Everything I've ever seen clearly states that a backlog of
> zero means that zero connections are allowed.
> 
> So we're not "disallowing" a backlog argument of zero to
> listen().  We'll accept that just fine, the only thing that
> happens is that you'll get what you ask for, that being
> no connections :-)

I'm not saying that a backlog of zero might mean allow one,
in which case we do need to revert the change.  Rather, I'm
trying to clarify what is the real issue here as Gerrit's
email implied that listen() with a zero backlog returns
an error now, which is not true.
