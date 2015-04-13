From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance
 regression on Xen
Date: Mon, 13 Apr 2015 06:49:30 -0700
Message-ID: <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
	 <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
	 <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	edumazet@google.com, linux-arm-kernel@lists.infradead.org,
	Christoffer Dall <christoffer.dall@linaro.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Jonathan Davies <Jonathan.Davies@citrix.com>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	Paul Durrant <paul.durrant@citrix.com>
To: George Dunlap <George.Dunlap@eu.citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-04-13 at 11:56 +0100, George Dunlap wrote:

> Is the problem perhaps that netback/netfront delays TX completion?
> Would it be better to see if that can be addressed properly, so that
> the original purpose of the patch (fighting bufferbloat) can be
> achieved while not degrading performance for Xen?  Or at least, so
> that people get decent perfomance out of the box without having to
> tweak TCP parameters?

Sure, please provide a patch, that does not break back pressure.

But just in case, if Xen performance relied on bufferbloat, it might be
very difficult to reach a stable equilibrium : Any small change in stack
or scheduling might introduce a significant difference in 'raw
performance'.
