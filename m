From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [E1000-devel] Transmission limit
Date: Tue, 30 Nov 2004 14:46:00 +0100
Message-ID: <20041130134600.GA31515@xi.wantstofly.org>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it> <41A73826.3000109@draigBrady.com> <16807.20052.569125.686158@robur.slu.se> <1101484740.24742.213.camel@mellia.lipar.polito.it> <41A76085.7000105@draigBrady.com> <1101499285.1079.45.camel@jzny.localdomain> <16811.8052.678955.795327@robur.slu.se> <1101821501.1043.43.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1101821501.1043.43.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 30, 2004 at 08:31:41AM -0500, jamal wrote:

> >  Also from what I understand new HW and MSI can help in the case where
> >  pass objects between CPU. Did I dream or did someone tell me that S2IO 
> >  could have several TX ring that could via MSI be routed to proper cpu?
> 
> I am wondering if the per CPU tx/rx irqs are valuable at all. They sound
> like more hell to maintain.

On the TX path you'd have qdiscs to deal with as well, no?


--L
