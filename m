From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Mon, 16 Jul 2012 23:43:33 +0300
Message-ID: <CAJZOPZL3F+xdHSFfhg7v9A6DDjT6CPK=kgwyzcE6c0pGYFyupg@mail.gmail.com>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com>
	<50044F1D.6000703@hp.com>
	<20120716190611.GA1023@oc1711230544.ibm.com>
	<50046EB1.5040909@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yevgenyp@mellanox.co.il" <yevgenyp@mellanox.co.il>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>,
	"leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>,
	"klebers@linux.vnet.ibm.com" <klebers@linux.vnet.ibm.com>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"anton@samba.org" <anton@samba.org>
To: Rick Jones <rick.jones2@hp.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:35398 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699Ab2GPUne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 16:43:34 -0400
Received: by yhmm54 with SMTP id m54so5777050yhm.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 13:43:34 -0700 (PDT)
In-Reply-To: <50046EB1.5040909@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 16, 2012 at 10:42 PM, Rick Jones <rick.jones2@hp.com> wrote:

> I was thinking more along the lines of an additional comparison,
> explicitly using netperf TCP_RR or something like it, not just the packets
> per second from a bulk transfer test.


TCP_STREAM from this setup before the patch would be good to know as well
