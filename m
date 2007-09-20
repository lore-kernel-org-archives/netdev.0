From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: netif_rx will not free skb when I use ftp in kernel 2.6.22/2.6.21
Date: Thu, 20 Sep 2007 08:02:39 -0500
Message-ID: <46F26F6F.60208@bellsouth.net>
References: <31156967.830941190260738334.JavaMail.coremail@bj126app89.126.com> <46F1F427.3060303@redhat.com>
Reply-To: jacliburn@bellsouth.net
Mime-Version: 1.0
Content-Type: text/plain; charset=x-gbk;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?x-gbk?Q?=D5=C5=B7=C9?= <zhangandfei@126.com>,
	netdev@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:55136 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbXITNCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 09:02:48 -0400
Received: by an-out-0708.google.com with SMTP id d31so77459and
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 06:02:47 -0700 (PDT)
In-Reply-To: <46F1F427.3060303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook wrote:
> =D5=C5=B7=C9 wrote:
>> in function=20
>> at_alloc_rx_buffers(), pci_unmap_page() and netif_rx() in function=20
>> at_clean_rx_irq(),=20

> Okay, I didn't know you were talking about the atl1 driver.  Are you=20
> using the
> in-tree driver in 2.6.22, or the pre-merge driver on sourceforge, or =
the=20
> vendor
> driver from Attansic/Atheros?

Based on the function names (at_*), looks like the vendor driver is=20
being used.
The pre-merge and in-kernel function names begin with atl1_.

Jay
