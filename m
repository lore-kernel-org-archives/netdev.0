From: jamal <hadi@cyberus.ca>
Subject: Re: [E1000-devel] Transmission limit
Date: 01 Dec 2004 07:25:44 -0500
Message-ID: <1101903944.1042.29.camel@jzny.localdomain>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com>
	 <1101483081.24742.174.camel@mellia.lipar.polito.it>
	 <20041127092503.GA12592@sunbeam.de.gnumonks.org>
	 <1101718412.14930.46.camel@verza.polito.it>
	 <20041129145028.GC18788@xi.wantstofly.org>
	 <1101804146.11111.23.camel@mellia.lipar.polito.it>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
        Harald Welte <laforge@gnumonks.org>, P@draigBrady.com,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mellia@prezzemolo.polito.it
In-Reply-To: <1101804146.11111.23.camel@mellia.lipar.polito.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-11-30 at 03:42, Marco Mellia wrote:
> On Mon, 2004-11-29 at 15:50, Lennert Buytenhek wrote:
> > On Mon, Nov 29, 2004 at 09:53:33AM +0100, Marco Mellia wrote:
> > 
> > > Th's our intuition too.
> > > Notice that we get the same results with 3com (broadcom based) gigabit
> > > cards.
> > > We are thinking of sending packet in "bursts" instead of single
> > > transfers. The only problem is to let the NIC know that there are more
> > > than a packet in a burst...
> > 
> > Jamal implemented exactly this for e1000 already, he might be persuaded
> > into posting his patch here.  Jamal? :)
> 
> I guess that saying that we are _very_ interested in this might help.
> :-)
> We can offer as "beta-testers" as well...

Sorry missed this (I wasnt CCed so it went to a low priority queue which
i read on a best effort basis).
Let me clean up the patches a little bit this weekend. The patch is at
least 4 months old; latest reincarnation was due to issue1 on my SUCON
presentation. Would a patch against latest 2.6.x bitkeeper (whatever it
is this weekend) be fine? If you are in a rush and dont mind a little
ugliness then i will pass them as is.

BTW, Scott posted a interesting patch yesterday, you may wanna give that
a shot as well. 

cheers,
jamal
