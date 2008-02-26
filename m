From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: problems with e1000 and flow control
Date: Tue, 26 Feb 2008 11:06:26 -0800
Message-ID: <47C46332.7040403@intel.com>
References: <200802252015.49862.wolfgang.walter@studentenwerk.mhn.de>
	<36D9DB17C6DE9E40B059440DB8D95F52047FCD70@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52047FCD70@orsmsx418.amr.corp.intel.com>
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

Brandeburg, Jesse wrote:
> Wolfgang Walter wrote:
>> it seems that e1000 enables flow-control (rx pause frames) even if
>> the switch does not advertise flow control. This seems to get a
>> problem as (at least some) switches then forward pause frames
>> directed to the card from other hosts. We think there are hosts which
>> indeed do this in the lans of our student halls.
>>
>> I think flow control should be completely disabled by default if the
>> switch does not advertise it. It still can be forced with ethtool.
> 
> We agree, and our latest standalone drivers have taken this into
> account, but the kernel drivers have not been updated all the way yet to
> fix this issue.

ok, that explains what is going on :)

I'll take a look into getting these changes upstream. Perhaps Wolfgang can confirm
that the driver on e1000.sf.net is properly working for him?

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
