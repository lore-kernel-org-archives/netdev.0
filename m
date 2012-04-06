From: "Hao, Xudong" <xudong.hao@intel.com>
Subject: Expose ltr/obff interface by sysfs
Date: Fri, 6 Apr 2012 02:43:59 +0000
Message-ID: <403610A45A2B5242BD291EDAE8B37D300FD0A434@SHSMSX102.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>
To: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
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

Hi, 

I'm working on virtualization Xen/KVM. I saw there are ltr/obff enabling/disabling function in pci.c, but no called till now. I want to know if anybody(driver developer) are working for using it? Can driver change the LTR latency value dynamically?

/*
LTR(Latency tolerance reporting) allows devices to send messages to the root complex indicating their latency tolerance for snooped & unsnooped memory transactions.
OBFF (optimized buffer flush/fill), where supported, can help improve energy efficiency by giving devices information about when interrupts and other activity will have a reduced power impact.
*/

One way to control ltr/obff is used by driver, however, I'm considering that in virtualization, how guest OS driver control them. I have an idea that expose an inode interface by sysfs, like "reset" inode implemented in pci-sysfs.c, so that system user/administrator can enable/disable ltr/obff or set latency value on userspace, but not limited on driver. Comments?

< pls CC me when reply this mail, thanks >

Best Regards,
Xudong Hao


------------------------------------------------------------------------------
For Developers, A Lot Can Happen In A Second.
Boundary is the first to Know...and Tell You.
Monitor Your Applications in Ultra-Fine Resolution. Try it FREE!
http://p.sf.net/sfu/Boundary-d2dvs2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
