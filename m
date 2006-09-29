From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 3/3] Add tsi108 On Chip Ethernet device driver support
Date: Fri, 29 Sep 2006 03:47:24 -0400
Message-ID: <451CCF8C.1000504@pobox.com>
References: <A0CDBA58F226D911B202000BDBAD46730A1B1410@zch01exm23.fsl.freescale.net>	 <1157962200.10526.10.camel@localhost.localdomain>	 <1158051351.14448.97.camel@localhost.localdomain>	 <ada3bax2lzw.fsf@cisco.com>  <4506C789.4050404@pobox.com>	 <1158749825.7973.9.camel@localhost.localdomain>	 <45121924.4000200@pobox.com> <1159515406.13634.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:19614 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965062AbWI2Hrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 03:47:33 -0400
To: Zang Roy-r61911 <tie-fei.zang@freescale.com>
In-Reply-To: <1159515406.13634.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zang Roy-r61911 wrote:
> Could you interpret the chip structure in more detail?
> Need I create two net_device struct for each port?

No.  One net_device per port.  And one container structure for the 
entire device.

	Jeff


