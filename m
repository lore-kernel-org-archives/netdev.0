From: jamal <hadi@cyberus.ca>
Subject: Re: [E1000-devel] Transmission limit
Date: 03 Dec 2004 08:07:49 -0500
Message-ID: <1102079268.1216.19.camel@jzny.localdomain>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com>
	 <1101483081.24742.174.camel@mellia.lipar.polito.it>
	 <20041127092503.GA12592@sunbeam.de.gnumonks.org>
	 <1101718412.14930.46.camel@verza.polito.it>
	 <20041129145028.GC18788@xi.wantstofly.org>
	 <1101804146.11111.23.camel@mellia.lipar.polito.it>
	 <1101903944.1042.29.camel@jzny.localdomain>
	 <1101994772.18491.16.camel@mellia.lipar.polito.it>
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
In-Reply-To: <1101994772.18491.16.camel@mellia.lipar.polito.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-12-02 at 08:39, Marco Mellia wrote:

> We'll be glad to spend some time trying this out. Please, we are not
> very confortable with the linux bitkeeper maintenance method. Can we ask
> you to provide us a patch to a standard kernel/driver (whatever you
> prefer...)? Also a complete source sub-tree would be ok ;-)

Would a -rcX patch be fine for you?
2.6.10-rc2; which means you willl take 2.6.9 patch it with the
patch-2.6.10-rc2.gz from kernel.org/v2.6/testing directory then
patch one more time with patch i give you. 
Let me know if you are uncomfortable with that as well.
[Sorry, I am disk poor and my stupid ISP still charges $1/MB/month even
in this age if i put it up at cyberus].

In the patch i give you i will include rx path improvement code that I
got from David Morsberger; I "think" i have seen some improvements with
it but i am not 100% sure. If you repeat the test where you drop the
packet right after eth_type_trans() with this patch on, I would be very
interested if you see any improvements.    
 
In any case, expect something from me this weekend or monday (big party
this weekend ;->).

cheers,
jamal
