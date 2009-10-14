From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/8] bnx2x: Device Control Channel bug fixes
Date: Wed, 14 Oct 2009 15:09:22 -0700 (PDT)
Message-ID: <20091014.150922.64618889.davem@davemloft.net>
References: <1255532825.25030.35.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59247
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753635AbZJNWJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 18:09:25 -0400
In-Reply-To: <1255532825.25030.35.camel@lb-tlvb-eilong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 14 Oct 2009 17:07:05 +0200

> This bnx2x patch series is fixing some bugs that relates to the Device
> Control Channel (DCC) code. There are actually 3 different failures:
> 
> 1. When the fairness initial value was set to zero, the device could not
> be enabled. This is caused since zero indicated that the mechanism is
> disabled, and the code (both FW and driver) was not ready to allow
> enabling it at run time. This patch requires replacing the FW - to allow
> easier review, it is split to 3 patches:
>         P1: adding the new FW
>         P2: the actually patch
>         P3: removing the old FW
>         
> 2. Races when loading/unloading the driver when DCC link enable/disable
> commands are received. There were 3 different races:
>         P4: The state of the driver which indicates if it is loaded or
>         not was also used to signal if its link is enabled/disabled by
>         DCC
>         P5: The FW commands to acknowledge the DCC command and
>         loading/unloading the driver run over each other
>         P6: Setting/clearing the MAC address and the FW filtering rules
>         
> 3.	P7: Reporting the maximal BW as the link speed
> 
> Patch number 8 is the version update.
> 
> The patches were made based on net-next. Since those are bug fixes,
> please let me know if I should send them based on net-2.6 as well.

Applied to net-next-2.6, which is where this likely belongs.

Thanks!
