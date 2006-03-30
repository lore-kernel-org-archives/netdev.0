From: Mark Nipper <nipsy@bitgnome.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Thu, 30 Mar 2006 02:24:41 -0600
Message-ID: <20060330082441.GA3149@king.bitgnome.net>
References: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jrlundgren@gmail.com, cat@zip.com.au, djani22@dynamicweb.hu,
	yoseph.basri@gmail.com, bb@kernelpanic.ru, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>, davem@davemloft.net,
	E1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Content-Disposition: inline
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

On 29 Mar 2006, Brandeburg, Jesse wrote:
> What I need from you is a reproducible test, and some information.  I
> have never been able to reproduce this, and I'm trying to isolate the
> problem a bit.  What motherboards are you using?  What seems to cause
> this problem?  Are you all using iptables?  Are you all routing? From
> the reports I assume none of you are using an 82571/2/3 (pci express)

        Unfortunately, my problem machine is a remote, leased
server, so I'd have to ask my provider for information on the
motherboard.  I have no specific idea what causes the problem as
the assertions simply show up after the fact in my logcheck
output.  I am not using iptables or routing.  And I'm fairly
certain the e1000 chip is just an integrated PCI device on the
motherboard.

> As far as I know e1000 has the same requirement as tg3 and some others
> where we have to modify the header of the skb in the case of transmits
> using TSO.  I don't see anywhere else that the driver modifies the skb.
> Tomorrow I'll generate a patch to try a more paranoid copying of the
> skb, I hope some of you can test.

        I'll be happy to test any patches you may have to narrow
down the problem.  I was actually considering running tcpdump or
ethereal or some such to try to capture the event on the network
side, but this probably isn't a wise idea considering it's a
production server and I do not have hands-on access to it.  A
patch which simply increased the verbosity of the event
(including counters and registers maybe?) would be preferable to
trying to capture an arbitrary amount of network traffic simply
waiting for the next time the assertion is triggered.

        Sorry for the real lack of data on this end.  But as I
said, any patch to help debug this is welcome.

-- 
Mark Nipper                                                e-contacts:
832 Tanglewood Drive                                nipsy@bitgnome.net
Bryan, Texas 77802-4013                     http://nipsy.bitgnome.net/
(979)575-3193                      AIM/Yahoo: texasnipsy ICQ: 66971617

-----BEGIN GEEK CODE BLOCK-----
Version: 3.1
GG/IT d- s++:+ a- C++$ UBL++++$ P--->+++ L+++$ !E---
W++(--) N+ o K++ w(---) O++ M V(--) PS+++(+) PE(--)
Y+ PGP t+ 5 X R tv b+++@ DI+(++) D+ G e h r++ y+(**)
------END GEEK CODE BLOCK------

---begin random quote of the moment---
I lost interest in "blade servers" when I found they didn't throw
knives at people who weren't supposed to be in your machine room.
  -- Anthony de Boer
----end random quote of the moment----


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
