From: Holger Eitzenberger <holger@my-eitzenberger.de>
Subject: [FIX NETLINK] properly check arguments to netlink_bind()
Date: Tue, 18 Sep 2007 23:01:08 +0200
Message-ID: <87fy1belij.fsf@kruemel.my-eitzenberger.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:52963 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbXIRVBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 17:01:24 -0400
Received: from holger by kruemel.my-eitzenberger.de with local (Exim 4.50)
	id 1IXkBw-00066W-Dp
	for netdev@vger.kernel.org; Tue, 18 Sep 2007 23:01:08 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

while going through going netlink code I found out that netlink_bind()
does not properly check bind parameters.  I checked both 2.6.23-rc1 as
well as 2.6.16.53, both are affected.

With a small test prog I wasn't able to crash my maschine though, but
data was accessed out of bounds.

Please apply the attached patch.

Thanks.

  /holger
