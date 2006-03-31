From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 09:22:32 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.63.0603310839070.3752@jbrandeb-desk.amr.corp.intel.com>
References: <200603311057.07213.netdev@axxeo.de> <20060331.013540.95485284.davem@davemloft.net>
 <20060331094240.GA11040@gondor.apana.org.au> <200603311418.47626.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, jesse.brandeburg@intel.com,
	nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, bb@kernelpanic.ru,
	mykleb@no.ibm.com, olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Ingo Oeser <netdev@axxeo.de>
In-Reply-To: <200603311418.47626.netdev@axxeo.de>
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



On Fri, 31 Mar 2006, Ingo Oeser wrote:

> Hi,
>
> Herbert Xu wrote:
>> On Fri, Mar 31, 2006 at 01:35:40AM -0800, David S. Miller wrote:
>>> He does not have TSO enabled, e1000 disables TSO when on a link speed
>>> slower than gigabit.
>
> dmesg|grep eth0
> [4294671.426000] e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> [4294679.125000] e1000: eth0: e1000_watchdog_task: NIC Link is Up 100 Mbps Full Duplex
>
>
> # ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: on
>
> So this theory doesn't seem to hold :-(
>
>> Indeed.  But I think that only happens on PCI Express and I don't think
>> Ingo is using PCI Express.
>
> Right. PCI-Express is not available in this machine.
>

First, thanks for all the responses.

6.3.9-k4 in 2.6.16 doesn't turn off TSO for 10/100, 7.0.33 in 2.6.17-pre 
does, I think that will help alleviate some of the confusion.

I've been working hard to try to reproduce here, no luck so far.

Herbert's fixes are interesting and appreciated.  I'm going to try to 
generate tests today that will show that the bugs he's mentioned could 
occur.

Jesse



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
