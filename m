From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13568] New: Intel e1000 4-port
 NIC - unable to communicate, slowly blinking
Date: Mon, 29 Jun 2009 16:00:03 -0700
Message-ID: <20090629160003.ea299eb5.akpm@linux-foundation.org>
References: <bug-13568-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	tuharsky@misbb.sk, bugme-daemon@bugzilla.kernel.org
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <bug-13568-10286@http.bugzilla.kernel.org/>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 18 Jun 2009 13:45:38 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13568
> 
>            Summary: Intel e1000 4-port NIC - unable to communicate, slowly
>                     blinking
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.30
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: tuharsky@misbb.sk
>         Regression: No
> 
> 
> Hallo,
> 
> I have here Tyan GT20 (B2865G20S4H) barebone server with onboard GbE NICs
> (Broadcom BCM5721 and Marvell 88E1111-CAA PHY).
> 
> I have installed PCI-E Intel__ PRO/1000 PT Quad Port Server Adapter
> (EXPI9404PTBLK) to gain 6 ports altogether. This is the card:
> 
> http://www.intel.com/products/server/adapters/pro1000pt-quadport/pro1000pt-quadport-overview.htm
> 
> Now, with Debian 5.0 Lenny (distributional kernel 2.6.26), only the onboard
> cards are functional. The Intel is also recognised by the kernel, is assigned
> ports (eth2-5), however none of them works when connected to network. The NIC
> is aware of plugging or un-plugging the cable (displays message on console),
> however no communication is ever performed, and the connected port just lazily
> blinks.
> 
> After some rochades hard to reproduce (plugging, unplugging, configuring
> interfaces, resetting etc), it even worked for few seconds, and then died out
> again forever.
> 
> I have also compiled fresh 2.6.30 kernel, no advance however. Interesting, that
> ifconfig always revails huge number of errors for the port.
> 


------------------------------------------------------------------------------
