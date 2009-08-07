From: "Paul Congdon \(UC Davis\)" <ptcongdon@ucdavis.edu>
Subject: RE: [Bridge] [PATCH] macvlan: add tap device backend
Date: Fri, 7 Aug 2009 12:47:38 -0700
Message-ID: <005601ca1797$ef5dc180$ce194480$@edu>
References: <0199E0D51A61344794750DC57738F58E6D6A6CD7F6@GVW1118EXC.americas.hpqcorp.net>	<004f01ca1792$b24a7a90$16df6fb0$@edu> <20090807123554.7c2bc27c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <drobbins@funtoo.org>, "'Fischer, Anna'" <anna.fischer@hp.com>,
	"'Arnd Bergmann'" <arnd@arndb.de>, <herbert@gondor.apana.org.au>,
	<mst@redhat.com>, <netdev@vger.kernel.org>,
	<bridge@lists.linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <ogerlitz@voltaire.com>,
	<evb@yahoogroups.com>, <davem@davemloft.net>
To: "'Stephen Hemminger'" <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933248AbZHGTrp@vger.kernel.org>
In-Reply-To: <20090807123554.7c2bc27c@nehalam>
Content-Language: en-us
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> I do have to raise the point that Linux is perfectly capable of keeping
> up without
> the need of an external switch.  Whether you want policy external or
> internal is
> a architecture decision that should not be driven by mis-information
> about performance.

No argument here.  I agree that you can do a lot in Linux.  It is, as you
say, an architecture decision, that can be enabled with this addition mode
of operation.  Without the mode of forcing things external, however, you
would always need to put this function internal or play games with VLANs
overlapping to get traffic to forward the way you want it.

Paul
