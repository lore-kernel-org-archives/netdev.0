From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: Setting alternate MAC addresses on e1000
Date: Wed, 2 Apr 2008 10:41:55 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5204D419D6@orsmsx418.amr.corp.intel.com>
References: <47F2358A.8080505@aei.mpg.de>
	<36D9DB17C6DE9E40B059440DB8D95F5204D09A67@orsmsx418.amr.corp.intel.com>
	<47F33EB6.1050402@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "Carsten Aulbert" <carsten.aulbert@aei.mpg.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <47F33EB6.1050402@aei.mpg.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Carsten Aulbert wrote:
> Yes, with MAGIC=0x109a8086 I can set the MAC address of eth1.

good, I think you need to just use that way.
 
> The Intel specs state that word 37H is a pointer to an "alternate MAC
> address". My boss things it would be wise to let the original MAC
> address in place and just add another MAC address, so that we can
> easily revert to the old "official" one by writing 0xffff into that
> word. 

The alternate MAC address typically refers to a MAC used only for
management/ASF/IPMI traffic.  I don't think that is what you want.

According to our internal documents that I have access to, word 37h is
not what you think it is on 82573V/L.

PXE Words (words 30h thru 3Eh)
Words 30h through 3Eh have been reserved for configuration and version
values to be used by PXE code.
 
> Has anyone experience with that approach? In principle that should be
> easy, however, I don't know where/how to find 6 free bytes from the
> table given in Intel's docs.
> 
> Thanks again and hopefully someone has some light for my brain ;)

I think that you should stick with programming the original MAC address.
Start messing around with other words and you're bound to get yourself
into trouble.

Jesse

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
