From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 14:18:46 +0200
Message-ID: <200603311418.47626.netdev@axxeo.de>
References: <200603311057.07213.netdev@axxeo.de> <20060331.013540.95485284.davem@davemloft.net> <20060331094240.GA11040@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	jesse.brandeburg@intel.com, nipsy@bitgnome.net, jrlundgren@gmail.com,
	cat@zip.com.au, djani22@dynamicweb.hu, yoseph.basri@gmail.com,
	bb@kernelpanic.ru, mykleb@no.ibm.com, olel@ans.pl, michal@feix.cz,
	chris@scorpion.nl, netdev@vger.kernel.org,
	jesse.brandeburg@gmail.com, E1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060331094240.GA11040@gondor.apana.org.au>
Content-Disposition: inline
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

Hi,

Herbert Xu wrote:
> On Fri, Mar 31, 2006 at 01:35:40AM -0800, David S. Miller wrote:
> > He does not have TSO enabled, e1000 disables TSO when on a link speed
> > slower than gigabit.

dmesg|grep eth0
[4294671.426000] e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
[4294679.125000] e1000: eth0: e1000_watchdog_task: NIC Link is Up 100 Mbps Full Duplex


# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: on

So this theory doesn't seem to hold :-(

> Indeed.  But I think that only happens on PCI Express and I don't think
> Ingo is using PCI Express.

Right. PCI-Express is not available in this machine.

Maybe the traffic is not enough to trigger it. External connect is just a 6MBit DSL.


Regards

Ingo Oeser


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
