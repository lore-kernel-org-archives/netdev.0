From: "Venkata Jagana" <jagana@us.ibm.com>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.45
Date: Thu, 31 Oct 2002 22:51:13 -0800
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <OFFA13F15A.27343A7E-ON88256C64.00238392@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, kkumar@beaverton.ibm.com, kuznet@ms2.inr.ac.ru,
	ajtuomin@tml.hut.fi, lpetande@tml.hut.fi, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@wide.ad.jp>
List-Id: netdev.vger.kernel.org




> Registration process should live in user space.

I believe even the registration part should belong to kernel and
here are the reasons why.

The Home Agent needs to consult the Binding Cache, which is stored
upon successful completion of Binding updates registration, for
tunnelling the packets belonging to the mobile nodes away from home.
In addition, as part of the registration process but before caching
the binding updates, the Home Agent may need to perform duplicate address
detection (DAD), if needed, through ND protocol messages. And also,
IPSec is mandated for Home Agent registration and so, Home Agent
must use IPSec for responding to Binding updates from Mobile Nodes.


Thanks,
Venkat

----------------------------------------------------------------
Venkata R Jagana
IBM Linux Technology Centre, Beaverton
jagana@us.ibm.com
Tel: (503) 578 3430 T/L 775-3430
