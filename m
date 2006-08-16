From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: e1000: ethtool -p + cable pull = system wedges
	hard
Date: Tue, 15 Aug 2006 22:13:50 -0700
Message-ID: <200608160513.k7G5DoZt018915@death.nxdomain.ibm.com>
References: <200608160037.k7G0btZt002839@death.nxdomain.ibm.com>
	<44E26EE7.3000100@intel.com> <44E28A95.9080802@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
To: Auke Kok <auke-jan.h.kok@intel.com>
In-reply-to: <44E28A95.9080802@intel.com> 
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Auke Kok <auke-jan.h.kok@intel.com> wrote:

>Auke Kok wrote:
>> Jay Vosburgh wrote:
>>> 	Running both 2.6.17.6 plus the e1000 7.2.7 from sourceforge, or
>>> the e1000 in netdev-2.6#upstream (7.1.9-k4).
>>>
>>> 	Starting up "ethtool -p ethX" then unplugging the cable
>>> connected to the identified port is causing my system to completely
>>> freeze; even sysrq is unresponsive.  I'm running on a 2-way x86 box,
>>> with an 82545GM.
>>>
>>> 	Is this by any chance a known problem?
>> not at all.
>
>One of my brain halves (the third one ;)) poked me and told me that it
>*is* a known issue. Not good. Apparently as early as kernel 2.5.50 a
>change was introduced that causes this. I am unsure what exactly caused it
>and I assume it is generic (other nic's might also suffer). The issue is
>documented in our standalone driver documentation. Not sure what to do
>with this.

	It appears to not be generic.  The same recipe on tg3 and e100
devices does not mete out the same frontier justice as e1000.  I made no
changes to the system (same one described above), tried it against
2.6.17.6 with whatever versions of tg3 and e100 it comes with.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
