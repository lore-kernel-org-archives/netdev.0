From: Madoka Komatsubara <m-komatsubara@ab.jp.nec.com>
Subject: Unable to receive multicast packet on VF
Date: Fri, 28 Mar 2014 11:49:05 +0000
Message-ID: <9DE5760509B7974286F38D93BF31DD62C7D0B8@BPXM13GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	Hiroshi Baba <h-baba@ax.jp.nec.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Language: ja-JP
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi all,


We would like to use multicast packet on the guest with Intel 82599EB SR-IOV.
However, the document says that adding the multicast MAC address to the VF 
is allowed during PF initialization only. (Please refer to the URL below.)
It means that we couldn't handle dynamically allocated multicast address.

On the other hand,
>From the data sheet, 82599EB has Multicast Promiscuous mode.
We could enable it on PF and all multicast packets are delivered to every VF.
That doesn't seem good, because each guest has to handle unnecessary packet.

Isn't it good to have a feature to add specific multicast address to VF?
Does anyone know that issue or the solution?



<http://www.intel.com/content/dam/www/public/us/en/documents/datasheets/82599-10-gbe-controller-datasheet.pdf>
 page585
 section 8.2.3.7.7
 "This table should be initialized by software before transmit and receive are enabled."

Regards,
Madoka Komatsubara

------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
