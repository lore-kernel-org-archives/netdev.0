From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek ethernet broken with 4.0-rc1 (invalid MAC address)
Date: Sat, 28 Feb 2015 12:54:38 +0100
Message-ID: <20150228115438.GA27600@electric-eye.fr.zoreil.com>
References: <2534A403-D18D-4CF5-919F-0A38285AA58F@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Jiang Liu <jiang.liu@linux.intel.com>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50598 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbbB1Lyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 06:54:43 -0500
Content-Disposition: inline
In-Reply-To: <2534A403-D18D-4CF5-919F-0A38285AA58F@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann <marcel@holtmann.org> :
[...]
> I am having the following Realtek ethernet card in the Minnowboard Max:
[...]
> When I am running the 4.0-rc1 kernel (4.0.0-0.rc1.git0.1.fc22.x86_64 to be
> precise), then the MAC address of this card is invalid:

Some crossposting is happening here.

For reference, the regression is worked on in the thread at
http://marc.info/?l=linux-kernel&m=142483609228207. Jiang Liu is taking
care of it.

Bottom line: host bridge resources misconfiguration.

-- 
Ueimor
