From: Sam Leffler <sam@errno.com>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Mon, 6 Sep 2004 21:32:49 -0700
Sender: acx100-devel-admin@lists.sourceforge.net
Message-ID: <200409062132.49356.sam@errno.com>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <757AB580-0030-11D9-9224-000A95AD0668@errno.com> <20040906182328.08faf843.davem@davemloft.net>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: vda@port.imtp.ilyichevsk.odessa.ua, jgarzik@pobox.com, netdev@oss.sgi.com,
   acx100-devel@lists.sourceforge.net, jt@bougret.hpl.hp.com,
   jkmaline@cc.hut.fi, prism54-devel@prism54.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040906182328.08faf843.davem@davemloft.net>
Content-Disposition: inline
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Monday 06 September 2004 06:23 pm, David S. Miller wrote:
> On Mon, 6 Sep 2004 11:13:31 -0700
>
> Sam Leffler <sam@errno.com> wrote:
> > I've suggested this code as a good starting point for a "generic 802.11
> > stack" but received only misinformed responses.
>
> Sam, I've told you multiple times why your stack isn't a good
> starting point.  It isn't implemented as a true network stack,
> like IPV4, Appletalk, etc.  Instead it's a gross input packet
> hooked packet eater thing that's an ugly wart bolted onto the
> side of the driver API.

Actually, this is the first time you've said anything to me about this code.  
We corresponded intensely for about a week 2+ years ago after which you 
declared you now knew how to "write an 802.11 stack right" and were going to 
do it that weekend.  I waited but it seems the sum total result was the shell 
of code that Jeff referenced in a previous note.

Perhaps you can point me at a description of what a "true network stack" means 
to you.  I'm guessing this has to do with your wanting queues inserted at 
various places instead of direct handoffs.  Regardless, I've never suggested 
the current code is suitable as-is but rather should be reshaped to suit the 
intended structure of the system.  There is a lot of hard-earned experience 
in the code that is independent of coding style and operational 
infrastructure.

Anyway, the point of my note was to correct a comment in the original posting 
and make folks aware that working code existed from which they could crib 
stuff.  Good luck finding someone to reimplement eveything according to your 
wishes.

	Sam


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
