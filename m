From: Phil Oester <kernel@linuxace.com>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Wed, 29 Mar 2006 20:25:50 -0800
Message-ID: <20060330042550.GA13183@linuxace.com>
References: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, bb@kernelpanic.ru,
	mykleb@no.ibm.com, olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
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

On Wed, Mar 29, 2006 at 06:53:57PM -0800, Brandeburg, Jesse wrote:
> Hi all, I've identified you as people who have at some point in the past
> emailed one of the Linux lists with problems with e1000 and
> sk_forward_alloc.  It seems to be fairly widespread, but only seems to
> have appeared with recent kernel changes (after 2.6.12...)
> 
> What I need from you is a reproducible test, and some information.  I
> have never been able to reproduce this, and I'm trying to isolate the
> problem a bit.  What motherboards are you using?  What seems to cause
> this problem?  Are you all using iptables?  Are you all routing? From
> the reports I assume none of you are using an 82571/2/3 (pci express)

Unfortunately it happens randomly, so I have no reproducible test.
Dell 1850s and 2850s here, no iptables, routing, or pci express.
lspci reports:

82541GI/PI Gigabit Ethernet Controller (rev 05)

> As far as I know e1000 has the same requirement as tg3 and some others
> where we have to modify the header of the skb in the case of transmits
> using TSO.  I don't see anywhere else that the driver modifies the skb.
> Tomorrow I'll generate a patch to try a more paranoid copying of the
> skb, I hope some of you can test.

I'll certainly try it as long as it doesn't blow things up :)

Phil


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
