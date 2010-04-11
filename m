From: David Miller <davem@davemloft.net>
Subject: Re: ssh server etc doesn't work anymore with net-2.6
Date: Sun, 11 Apr 2010 02:43:52 -0700 (PDT)
Message-ID: <20100411.024352.209996508.davem@davemloft.net>
References: <r2v86802c441004110217u15591f95ydd1e8e1466a36dc2@mail.gmail.com>
	<20100411.022416.107236208.davem@davemloft.net>
	<u2v86802c441004110232l99be1450w4e629ab2bde9bc0c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org
To: yinghai@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33603
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751615Ab0DKJnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 05:43:49 -0400
In-Reply-To: <u2v86802c441004110232l99be1450w4e629ab2bde9bc0c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinghai Lu <yinghai@kernel.org>
Date: Sun, 11 Apr 2010 02:32:33 -0700

> server side: 82576 with net-2.6
> client side: opensuse 11.2 on thinkpad T61 wireless + vpnc

I've pushed out a revert, we'll sort this out in net-next-2.6
and meanwhile I've started a dialog with the Intel driver
folks to see if there IGB chip has a problem with handling
CHECKSUM_PARTIAL packets with a zero length data area.

Thanks for your report.
