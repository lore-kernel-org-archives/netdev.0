From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: Re: No link on e1000e with 2.6.35.3 and ThinkPad T60
Date: Thu, 26 Aug 2010 15:31:07 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A13660082E9090@rrsmsx501.amr.corp.intel.com>
References: <20100724092644.GA13353@torres.zugschlus.de>
	<20100824094524.GA17608@torres.zugschlus.de>
	<EA929A9653AAE14F841771FB1DE5A136600821444B@rrsmsx501.amr.corp.intel.com>
	<20100826112732.GA15559@torres.zugschlus.de>
	<20100826171442.GA22941@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marc Haber <mh+linux-kernel@zugschlus.de>, Linux Kernel Developers
	<linux-kernel@vger.kernel.org>, Linux Kernel Network Developers
	<netdev@vger.kernel.org>, "e1000-devel@lists.sourcefo
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100826171442.GA22941@torres.zugschlus.de>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Marc Haber wrote:
> On Thu, Aug 26, 2010 at 01:27:32PM +0200, Marc Haber wrote:
>> On Wed, Aug 25, 2010 at 12:01:40PM -0600, Tantilov, Emil S wrote:
>>> We have a tool that you can use to dump the registers from the port
>>> in the failed state:
>>> http://sourceforge.net/projects/e1000/files/Ethregs%20-%20Register%20Dump%20Tool/ethregs-1.12.3/
>> 
>> Attached, for an interface in the working state. I'll deliver another
>> regdump when I see the issue again
> 
> Here we go, with a non-working interface.

After reviewing the output from dmidecode I determined that your model T60 is slightly different than mine. It appears that you have the widescreen version. Is that correct?

Also you seem to be running a fairly old version of the BIOS (1.08). The latest is 1.18:
http://www-307.ibm.com/pc/support/site.wss/MIGR-67020.html

I would recommend that you upgrade your BIOS. If that does not help we can continue with the investigation. I will also try to locate a widescreen T60 that would hopefully help me with the repro. 

The model I have has been running all kinds of stress since you first reported this issue, and so far is rock solid.

> 
> Greetings
> Marc


Thanks,
Emil
------------------------------------------------------------------------------
Sell apps to millions through the Intel(R) Atom(Tm) Developer Program
Be part of this innovative community and reach millions of netbook users 
worldwide. Take advantage of special opportunities to increase revenue and 
speed time-to-market. Join now, and jumpstart your future.
http://p.sf.net/sfu/intel-atom-d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
