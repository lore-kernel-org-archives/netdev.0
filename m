From: David Miller <davem@davemloft.net>
Subject: Re: packet received in a wrong rx-queue?
Date: Wed, 18 May 2011 23:36:14 -0400 (EDT)
Message-ID: <20110518.233614.1134947771941589398.davem@davemloft.net>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D749114@MILEXCH2.ds.jdsu.net>
	<20110518.213225.1546509125052154115.davem@davemloft.net>
	<4A6A2125329CFD4D8CC40C9E8ABCAB9F250D7491A8@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jon.Zhou@jdsu.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D7491A8@MILEXCH2.ds.jdsu.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jon Zhou <Jon.Zhou@jdsu.com>
Date: Wed, 18 May 2011 20:22:07 -0700

> form the 82599 datasheet, the hash algorithm is consist of src/dst
> ip, src/dst port,protocol why it got different hash value with same
> ip/port pair?

The same reason why feeding different sets of discrete 32-bit and
16-bit values to a cryptographic hash results in a different final
hash value.

Our software RPS/RFS implementation used to have this quality too.

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
