From: Marco Mellia <mellia@prezzemolo.polito.it>
Subject: Re: [E1000-devel] Transmission limit
Date: 29 Nov 2004 18:32:13 +0100
Message-ID: <1101749533.17091.3.camel@verza.polito.it>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com>
	 <20041127200030.GD27762@xi.wantstofly.org>
	 <1101732267.14930.75.camel@verza.polito.it>
	 <20041129151940.GA19184@xi.wantstofly.org>
Reply-To: mellia@prezzemolo.polito.it
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marco Mellia <mellia@prezzemolo.polito.it>,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041129151940.GA19184@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Using the Agilent Router tester as receiver...
:-(

> On Mon, Nov 29, 2004 at 01:44:27PM +0100, Marco Mellia wrote:
> 
> > This "resets" the registers and writes in the TDFPC that there are 10
> > pkts in the TX queue.
> > Now when we do:
> > 
> > ping -c 1 x.x.x.x
> > 
> > You will see that the NIC will transmit 11 pkts (10 we "preloaded" + the
> > new one).
> > If you try to measure the TX speed you will see that it is ~ the wire
> > speed.
> 
> How are you measuring this?
> 
> 
> cheers,
> Lennert
-- 
Ciao,                    /\/\/\rco

+-----------------------------------+  
| Marco Mellia - Assistant Professor|
| Tel: 39-011-2276-608              |
| Tel: 39-011-564-4173              |
| Cel: 39-340-9674888               |   /"\  .. . . . . . . . . . . . .
| Politecnico di Torino             |   \ /  . ASCII Ribbon Campaign  .
| Corso Duca degli Abruzzi 24       |    X   .- NO HTML/RTF in e-mail .
| Torino - 10129 - Italy            |   / \  .- NO Word docs in e-mail.
| http://www1.tlc.polito.it/mellia  |        .. . . . . . . . . . . . .
+-----------------------------------+
The box said "Requires Windows 95 or Better." So I installed Linux.
