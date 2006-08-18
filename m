From: Daniel Drake <dsd@gentoo.org>
Subject: Reasons behind HAVE_TX_TIMEOUT
Date: Fri, 18 Aug 2006 11:55:40 +0100
Message-ID: <44E59CAC.9010300@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:64198 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751356AbWHRKoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 06:44:37 -0400
Received: from aamtaout03-winn.ispmail.ntl.com ([81.103.221.35])
          by mtaout02-winn.ispmail.ntl.com with ESMTP
          id <20060818104436.KFQS27023.mtaout02-winn.ispmail.ntl.com@aamtaout03-winn.ispmail.ntl.com>
          for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 11:44:36 +0100
Received: from [192.168.0.2] (really [86.14.216.162])
          by aamtaout03-winn.ispmail.ntl.com with ESMTP
          id <20060818104436.LVJU11710.aamtaout03-winn.ispmail.ntl.com@[192.168.0.2]>
          for <netdev@vger.kernel.org>; Fri, 18 Aug 2006 11:44:36 +0100
To: Netdev list <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Just curious, why do we have an unconditional #define in netdevice.h for 
HAVE_TX_TIMEOUT, and some drivers (e.g. xirc2ps_cs) using it 
conditionally as if it might be disabled on some builds?

There are other similar defines in netdevice.h too.

Thanks,
Daniel
