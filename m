From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net-next 8/9] ixgbe: add interface to export thermal data
Date: Fri, 23 Dec 2011 21:45:43 +0100
Message-ID: <20111223204543.GB32637@electric-eye.fr.zoreil.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com> <1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com> <20111223130148.GB27206@electric-eye.fr.zoreil.com> <F6FB0E698C9B3143BDF729DF22286646E087@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38940 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757694Ab1LWUxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 15:53:54 -0500
Content-Disposition: inline
In-Reply-To: <F6FB0E698C9B3143BDF729DF22286646E087@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Skidmore, Donald C <donald.c.skidmore@intel.com> :
[...]
> I like all your suggestions and will do the clean up.
> 
> Thanks again for the great review. :)

Depending on how you plan to use ixgbe_init_thermal_sensor_thresh_generic,
the memset(..., 0, ...) may be removed since it is applied within the
device own kzalloced struct ixgbe_hw.

I must confess I have not looked too closely at the sysfs code.

-- 
Ueimor
