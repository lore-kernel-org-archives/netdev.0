From: jamal <hadi@cyberus.ca>
Subject: Re: [E1000-devel] Transmission limit
Date: 03 Dec 2004 08:24:49 -0500
Message-ID: <1102080289.1214.22.camel@jzny.localdomain>
References: <1101484740.24742.213.camel@mellia.lipar.polito.it>
	 <41A76085.7000105@draigBrady.com>
	 <1101499285.1079.45.camel@jzny.localdomain>
	 <16811.8052.678955.795327@robur.slu.se>
	 <1101821501.1043.43.camel@jzny.localdomain>
	 <20041130134600.GA31515@xi.wantstofly.org>
	 <1101824754.1044.126.camel@jzny.localdomain>
	 <20041201001107.GE4203@xi.wantstofly.org>
	 <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
	 <20041201182943.GA14470@xi.wantstofly.org>
	 <20041201213550.GF14470@xi.wantstofly.org>
	 <1101967983.4782.9.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sfeldma@pobox.com
In-Reply-To: <1101967983.4782.9.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-12-02 at 01:13, Scott Feldman wrote:
> On Wed, 2004-12-01 at 13:35, Lennert Buytenhek wrote: 
> > Pretty graph attached.  From ~220B packets or so it does wire speed, but
> > there's still an odd drop in performance around 256B packets (which is
> > also there without your patch.)  From 350B packets or so, performance is
> > identical with or without your patch (wire speed.)
>
> Seems this is helping PCI nics but not PCI-X.  I was using PCI 32/33. 
> Can't explain the dip around 256B.
> 

Interesting thought. I also saw improvements with my batching patch for
PCI 32/32 but nothing noticeable in PCI-X 64/66.

cheers,
jamal
