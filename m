From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: packet received in a wrong rx-queue?
Date: Wed, 18 May 2011 02:00:50 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D748939@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
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

There are 2 packets in the traffic

#1 create PDP context request, IPV4--UDP--GTP, src_ip=A and dst_ip=B,src_port=C,dst_port=D

#2 create PDP context response, IPV4--UDP--GTP,src_ip=B, dst_ip=A, src_port=D,dst_port=C

I suppose both of them will be received in same rx-queue but actually it doesn't
Anything need to check?

ethtool -i eth5
driver: ixgbe
version: 3.3.9-NAPI
firmware-version: 0.9-3
bus-info: 0000:08:00.1

regards
jon





------------------------------------------------------------------------------
What Every C/C++ and Fortran developer Should Know!
Read this article and learn how Intel has extended the reach of its 
next-generation tools to help Windows* and Linux* C/C++ and Fortran 
developers boost performance applications - including clusters. 
http://p.sf.net/sfu/intel-dev2devmay
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
