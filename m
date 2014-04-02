From: Madoka Komatsubara <m-komatsubara@ab.jp.nec.com>
Subject: RE: Unable to receive multicast packet on VF
Date: Wed, 2 Apr 2014 09:04:47 +0000
Message-ID: <9DE5760509B7974286F38D93BF31DD62C7DF52@BPXM13GP.gisp.nec.co.jp>
References: <9DE5760509B7974286F38D93BF31DD62C7D0B8@BPXM13GP.gisp.nec.co.jp>
 <F6FB0E698C9B3143BDF729DF2228664685D9725C@ORSMSX110.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	Hiroshi Baba <h-baba@ax.jp.nec.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([210.143.35.51]:64481 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758151AbaDBJHk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 05:07:40 -0400
In-Reply-To: <F6FB0E698C9B3143BDF729DF2228664685D9725C@ORSMSX110.amr.corp.intel.com>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: Skidmore, Donald C [mailto:donald.c.skidmore@intel.com]
> Sent: Saturday, March 29, 2014 5:54 AM
> To: Komatsubara Madoka(小松原 円); linux-kernel@vger.kernel.org;
> e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
> Cc: Shimamoto Hiroshi(島本 裕志); Baba Hiroshi(馬場 裕司)
> Subject: RE: Unable to receive multicast packet on VF
> 
> 
> 
> > -----Original Message-----
> > From: Madoka Komatsubara [mailto:m-komatsubara@ab.jp.nec.com]
> > Sent: Friday, March 28, 2014 4:49 AM
> > To: linux-kernel@vger.kernel.org; e1000-devel@lists.sourceforge.net;
> > netdev@vger.kernel.org
> > Cc: Hiroshi Shimamoto; Hiroshi Baba
> > Subject: [E1000-devel] Unable to receive multicast packet on VF
> >
> > Hi all,
> >
> >
> > We would like to use multicast packet on the guest with Intel 82599EB
> > SR- IOV.
> > However, the document says that adding the multicast MAC address to
> > the VF is allowed during PF initialization only. (Please refer to the
> > URL below.) It means that we couldn't handle dynamically allocated multicast
> address.
> >
> > On the other hand,
> > >From the data sheet, 82599EB has Multicast Promiscuous mode.
> > We could enable it on PF and all multicast packets are delivered to every
> VF.
> > That doesn't seem good, because each guest has to handle unnecessary
> > packet.
> >
> > Isn't it good to have a feature to add specific multicast address to VF?
> > Does anyone know that issue or the solution?
> >
> >
> >
> > <http://www.intel.com/content/dam/www/public/us/en/documents/datas
> > heets/82599-10-gbe-controller-datasheet.pdf>
> >  page585
> >  section 8.2.3.7.7
> >  "This table should be initialized by software before transmit and
> > receive are enabled."
> >
> > Regards,
> > Madoka Komatsubara
> >
> 
> Hi Madoka,
> 
> You can see where we are changing the multicast address list in the VF driver
> in ixgbevf_set_rx_mode().  This not only called via ndo_set_rx_mode but in
> our up and open calls.   So while it is true this needs to be initialized before
> transmit and receive are enabled, the value can be changed without requiring
> the module to be reloaded.
> 
> Hope that helps,
> -Don


Hi Donald,

Thank you for your information.
it is currently under consideration.
I will contact you again later.


Regards,
Madoka Komatsubara
