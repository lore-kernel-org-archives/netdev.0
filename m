From: Ben Greear <greearb@candelatech.com>
Subject: Re: e1000 and 802.1ad/stacked vlan tagging
Date: Mon, 28 Aug 2006 14:54:28 -0700
Message-ID: <44F36614.3030609@candelatech.com>
References: <36D9DB17C6DE9E40B059440DB8D95F5286678F@orsmsx418.amr.corp.intel.com>
	<20060828193832.359651a1.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Brandeburg,  Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
To: Stephan von Krawczynski <skraw@ithnet.com>
In-Reply-To: <20060828193832.359651a1.skraw@ithnet.com>
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

Stephan von Krawczynski wrote:
> Hello Jesse,
> 
> thank you for answering anyway. Though I think your answer covers only the
> obvious half of the problem.
> Indeed one might think that this solves the issue - as long as there are only
> linux kernels involved. Unfortunately my setup is a bit more complicated in
> terms of hardware. So I should have probably clarified the question this way:
> how do you configure the interface in a manner that packets with data length
> of 1500 get transferred, and not only 1496 ?
> I tried enlarging both real-device and first vlan interface mtu but that does
> not work out. I really thought that the visible device setting of mtu=1500
> should have worked out and that the driver (or some code in between) should
> have corrected the allowed frame size to reflect the actual setup, not?

Unless you are patching the VLAN code, stacked VLANs are not going to 
work anyway.  Search the archives of the VLAN mailing list for reasons 
why..and at least a few patches that 'fix' the problem for a few types 
of uses.

Ben

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
