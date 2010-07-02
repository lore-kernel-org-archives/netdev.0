From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: e1000e: receives no packets after resume
	(2.6.35-rc3-00262-g984bc96)
Date: Fri, 2 Jul 2010 14:47:26 -0700
Message-ID: <AANLkTikO8yXXBC9Wt4LKZeu1JD5TKMOW5reB3jpk8Ahp@mail.gmail.com>
References: <20100702072826.GB16856@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>
To: Nico Schottelius <nico-linux-20100702@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100702072826.GB16856@schottelius.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, Jul 2, 2010 at 00:28, Nico Schottelius
<nico-linux-20100702@schottelius.org> wrote:
> Good morning hackers,
>
> I've seen that in kernels before, but now suffering from it:
> e1000e does not receive any packets after third resume:
>
> --------------------------------------------------------------------------------
> [8:16] kr:clyde# dhcpcd eth0
> dhcpcd[11589]: version 5.2.5 starting
> dhcpcd[11589]: eth0: rebinding lease of 129.132.102.115
> dhcpcd[11589]: eth0: broadcasting for a lease
> ^Cdhcpcd[11589]: received SIGINT, stopping
> dhcpcd[11589]: eth0: removing interface
> [8:16] kr:clyde# dhcpcd eth0
> dhcpcd[11601]: version 5.2.5 starting
> dhcpcd[11601]: eth0: rebinding lease of 129.132.102.115
> dhcpcd[11601]: eth0: broadcasting for a lease
> ^Cdhcpcd[11601]: received SIGINT, stopping
> dhcpcd[11601]: eth0: removing interface
> [8:16] kr:clyde# dhcpcd eth0
> dhcpcd[11784]: version 5.2.5 starting
> dhcpcd[11784]: eth0: rebinding lease of 129.132.102.115
> ^Cdhcpcd[11784]: received SIGINT, stopping
> dhcpcd[11784]: eth0: removing interface
> [8:16] kr:clyde# dhcpcd eth0
> dhcpcd[11830]: version 5.2.5 starting
> dhcpcd[11830]: eth0: rebinding lease of 129.132.102.115
> dhcpcd[11830]: eth0: broadcasting for a lease
> dhcpcd[11830]: timed out
> [8:17] kr:clyde# rmmod e1000e
> [8:18] kr:clyde# modprobe e1000e
> [8:18] kr:clyde# dhcpcd eth0
> dhcpcd[11855]: version 5.2.5 starting
> dhcpcd[11855]: eth0: waiting for carrier
> ^Cdhcpcd[11855]: received SIGINT, stopping
> dhcpcd[11855]: eth0: removing interface
> [8:18] kr:clyde# dhcpcd eth0
> dhcpcd[11871]: version 5.2.5 starting
> dhcpcd[11871]: eth0: rebinding lease of 129.132.102.115
> dhcpcd[11871]: eth0: acknowledged 129.132.102.115 from 129.132.57.97
> dhcpcd[11871]: eth0: checking for 129.132.102.115
> dhcpcd[11871]: eth0: leased 129.132.102.115 for 86400 seconds
> dhcpcd[11871]: forked to background, child pid 11892
> [8:18] kr:clyde#
> --------------------------------------------------------------------------------
>
> Are you aware of this issues?
>
> Cheers,
>
> Nico
>
> --

Adding the Networking Kernel mailing list (netdev) and Intel Linux LAN
Driver mailing list (e1000-patches)...

Would it be possible to get more information about the system/setup?

For example, can you provide the following information:
     - full lspci output (lspci -vvv)
     - ethtool -i ethX
     - dmesg  - after loading the driver and configuring the interfaces
     - kernel config

-- 
Cheers,
Jeff

------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
