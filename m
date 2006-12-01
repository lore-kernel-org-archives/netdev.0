From: David Miller <davem@davemloft.net>
Subject: Re: pktgen
Date: Fri, 01 Dec 2006 15:25:51 -0800 (PST)
Message-ID: <20061201.152551.56052748.davem@davemloft.net>
References: <20061130.201423.118625277.davem@davemloft.net>
	<17775.58441.678623.396102@robur.slu.se>
	<b6fcc0a0612010151s4231cae6n9252f8816406e1d2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, greearb@candelatech.com,
	pavol.gono@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:7853
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1162338AbWLAXZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 18:25:45 -0500
To: adobriyan@gmail.com
In-Reply-To: <b6fcc0a0612010151s4231cae6n9252f8816406e1d2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Alexey Dobriyan" <adobriyan@gmail.com>
Date: Fri, 1 Dec 2006 12:51:53 +0300

> On 12/1/06, Robert Olsson <Robert.Olsson@data.slu.se> wrote:
> > David Miller writes:
> >  > Agreed.
> >  >
> >  > Robert, please fix this by using a completion so that we can
> >  > wait for the threads to start up, something like this:
> >
> > Included. It passes my test but Alexey and others test.
> 
> Confused now. Is my "t->control &= ~(T_TERMINATE);" fix deprecated by
> completions?

The completions solve the bug completely.

But later on we should integate a change that eliminates
these spurious t->control bit clears at the start of the
pktgen thread execution, it just isn't needed to fix the
bug so we can make it later.
