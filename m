From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH net-next-2.6 0/8] Get rid of net_device_stats from adapter.
Date: Wed, 7 Oct 2009 18:11:40 +0530
Message-ID: <20091007124129.GA29781@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:62579 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404AbZJGMm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 08:42:28 -0400
Received: by bwz6 with SMTP id 6so25663bwz.37
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 05:41:50 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since net_device already has an instance of net_device stats,
its not necessary for the drivers to maintain their own copy
in their private adapter structure.
This patch series takes care of this for some of the drivers.
I have compiled them all in my setup. 
And not all of them have been tested.  :-)

Thanks
-Ajit
