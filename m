From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: No link on e1000e with 2.6.35.3 and ThinkPad T60
Date: Sat, 4 Sep 2010 08:33:05 +0200
Message-ID: <20100904063305.GA18734@torres.zugschlus.de>
References: <20100724092644.GA13353@torres.zugschlus.de>
	<20100824094524.GA17608@torres.zugschlus.de>
	<EA929A9653AAE14F841771FB1DE5A136600821444B@rrsmsx501.amr.corp.intel.com>
	<20100826112732.GA15559@torres.zugschlus.de>
	<20100826171442.GA22941@torres.zugschlus.de>
	<EA929A9653AAE14F841771FB1DE5A13660082E9090@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A13660082E9090@rrsmsx501.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Aug 26, 2010 at 03:31:07PM -0600, Tantilov, Emil S wrote:
> Marc Haber wrote:
> > On Thu, Aug 26, 2010 at 01:27:32PM +0200, Marc Haber wrote:
> >> On Wed, Aug 25, 2010 at 12:01:40PM -0600, Tantilov, Emil S wrote:
> >>> We have a tool that you can use to dump the registers from the port
> >>> in the failed state:
> >>> http://sourceforge.net/projects/e1000/files/Ethregs%20-%20Register%20Dump%20Tool/ethregs-1.12.3/
> >> 
> >> Attached, for an interface in the working state. I'll deliver another
> >> regdump when I see the issue again
> > 
> > Here we go, with a non-working interface.
> 
> After reviewing the output from dmidecode I determined that your model
> T60 is slightly different than mine. It appears that you have the
> widescreen version. Is that correct?

The dmidecode output is from the widescreen model, yes, but I also
have two "normal" T60 with the non-wide screen 15" display (with
1400x1050 pixels). The freezes happen on all three. The one I have at
hand is running BIOS 2.26 dated 2010-04-01. I will also try updating
the Widescreen unit which is - not surprisingly - the one I use the
most.

> Also you seem to be running a fairly old version of the BIOS (1.08).
> The latest is 1.18:
> http://www-307.ibm.com/pc/support/site.wss/MIGR-67020.html

Thanks for that pointer, I am having difficulties in navigating the
IBM/Lenovo web sites.

> I would recommend that you upgrade your BIOS. If that does not help we
> can continue with the investigation. I will also try to locate a
> widescreen T60 that would hopefully help me with the repro. 

I can give you ssh access to mine if you want to. Do you have IPv6
connectivity? If you want me to, send me your ssh key.

> The model I have has been running all kinds of stress since you first
> reported this issue, and so far is rock solid.

Please note that usually the freezes happen when the network is rather
slightly loaded, for example when I'm typing into an ssh window with
nothing else happening on the box. When I do things that are rather
traffic intensive such as a backup, the box is fine. The "no link"
issue appears most frequently on a system that has been running for
some time and suspend-to-ram was used. I am traveling a lot, and every
change of train or bus involves a suspend-resume cycle.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190

------------------------------------------------------------------------------
This SF.net Dev2Dev email is sponsored by:

Show off your parallel programming skills.
Enter the Intel(R) Threading Challenge 2010.
http://p.sf.net/sfu/intel-thread-sfd
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
