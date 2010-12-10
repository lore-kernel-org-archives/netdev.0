From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] atm: correct sysfs 'device' link creation and
 parent relationships
Date: Fri, 10 Dec 2010 15:45:33 -0800 (PST)
Message-ID: <20101210.154533.124001355.davem@davemloft.net>
References: <20101208.121532.232745367.davem@davemloft.net>
	<1291854831.16839.12.camel@dcbw.foobar.com>
	<1291873251.24551.4.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, netdev@vger.kernel.org, duncan.sands@free.fr,
	linux-usb@vger.kernel.org, chas@cmf.nrl.navy.mil
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59406
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751916Ab0LJXpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 18:45:06 -0500
In-Reply-To: <1291873251.24551.4.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Wed, 08 Dec 2010 23:40:47 -0600

> The ATM subsystem was incorrectly creating the 'device' link for ATM
> nodes in sysfs.  This led to incorrect device/parent relationships
> exposed by sysfs and udev.  Instead of rolling the 'device' link by hand
> in the generic ATM code, pass each ATM driver's bus device down to the
> sysfs code and let sysfs do this stuff correctly.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>

Applied and being compile tested :-)

Thanks!
