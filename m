From: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Subject: Re: fail to add 64 VLANs or more when SR-IOV is
 enabled
Date: Fri, 4 Apr 2014 21:29:47 +0000
Message-ID: <9B4A1B1917080E46B64F07F2989DADD65297912C@ORSMSX102.amr.corp.intel.com>
References: <9DE5760509B7974286F38D93BF31DD62C7DF93@BPXM13GP.gisp.nec.co.jp>
	<9B4A1B1917080E46B64F07F2989DADD652978166@ORSMSX102.amr.corp.intel.com>
	<9DE5760509B7974286F38D93BF31DD62C7E125@BPXM13GP.gisp.nec.co.jp>
	<20140402.213941.1530194697006154708.davem@davemloft.net>
	<9DE5760509B7974286F38D93BF31DD62C7E200@BPXM13GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	Hiroshi Baba <h-baba@ax.jp.nec.com>
To: Madoka Komatsubara <m-komatsubara@ab.jp.nec.com>, David Miller
	<davem@davemloft.net>, "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <9DE5760509B7974286F38D93BF31DD62C7E200@BPXM13GP.gisp.nec.co.jp>
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

You can have more than 64 VLANs, but not for a single VF.

Todd Fujinaka
Software Application Engineer
Networking Division (ND)
Intel Corporation
todd.fujinaka@intel.com
(503) 712-4565


-----Original Message-----
From: Madoka Komatsubara [mailto:m-komatsubara@ab.jp.nec.com] 
Sent: Wednesday, April 02, 2014 7:04 PM
To: David Miller; Fujinaka, Todd; Skidmore, Donald C; linux-kernel@vger.kernel.org; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
Cc: Hiroshi Shimamoto; Hiroshi Baba
Subject: RE: [E1000-devel] fail to add 64 VLANs or more when SR-IOV is enabled


> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, April 03, 2014 10:40 AM
> To: Komatsubara Madoka(小松原 円)
> Cc: todd.fujinaka@intel.com; donald.c.skidmore@intel.com; 
> linux-kernel@vger.kernel.org; e1000-devel@lists.sourceforge.net;
> netdev@vger.kernel.org; Shimamoto Hiroshi(島本 裕志); Baba Hiroshi(馬場 裕
> 司)
> Subject: Re: [E1000-devel] fail to add 64 VLANs or more when SR-IOV is 
> enabled
> 
> From: Madoka Komatsubara <m-komatsubara@ab.jp.nec.com>
> Date: Thu, 3 Apr 2014 01:12:13 +0000
> 
> > Thank you for the quick response.
> > How can I increase the limit？
> 
> It's a hardware limit, you cannot increase it.


Thank you for your information.
Does it mean disabling filter is the only way to use over 64 VLANs and is it possible?

Regards,
Madoka


------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
