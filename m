From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Tue, 10 Jul 2012 16:45:58 +0200
Message-ID: <1341931558.3265.5399.camel@edumazet-glaptop>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	 <1341474192.2583.3299.camel@edumazet-glaptop>
	 <CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	 <1341477192.2583.3415.camel@edumazet-glaptop>
	 <CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	 <1341481760.2583.3579.camel@edumazet-glaptop>
	 <CACVXFVNYwNrdWS_EiQ4O0-ou369AQ2tB4qbvmzY1rt5T3QnyUw@mail.gmail.com>
	 <1341842043.3265.2914.camel@edumazet-glaptop>
	 <CACVXFVNdiwVn1Mo--N4N0HdYrEJizExtd_cppT4tS=mjog2PKw@mail.gmail.com>
	 <1341895143.3265.4049.camel@edumazet-glaptop>
	 <CACVXFVPgqtSN3BrEXRxSv4yxaxCni495SxZNXBmYQpagmxk2tQ@mail.gmail.com>
	 <1341908908.3265.4508.camel@edumazet-glaptop>
	 <CACVXFVM-fhQJX+EFNoFSnuVAjqfRM7OjzbQML7H+tMEjxG7Rug@mail.gmail.com>
	 <1341928931.3265.5263.camel@edumazet-glaptop>
	 <CACVXFVPmec5_3Up9qM4iA90Xua9J_E-aRT-2g7Hu7TR4zRKQtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33720 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033Ab2GJOqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 10:46:04 -0400
Received: by eeit10 with SMTP id t10so26326eei.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 07:46:02 -0700 (PDT)
In-Reply-To: <CACVXFVPmec5_3Up9qM4iA90Xua9J_E-aRT-2g7Hu7TR4zRKQtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 22:22 +0800, Ming Lei wrote:

> Looks single page allocation won't put too much pressure on MM, that is
> why I suggested to avoid copy if the skb buffer size is less or equal one
> page. Anyway, unnecessary copy will increase computation and consume power.

AFAIK this long thread started with drivers/net/usb/smsc95xx.c using
32KB buffers, thats order-3 pages, not 'single page'

Definitely very wrong. You can try to claim the contrary, it wont be
wise.
