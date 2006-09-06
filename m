From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2.6.19 PATCH 1/7] ehea: interface to network stack
Date: Wed, 06 Sep 2006 11:22:16 -0400
Message-ID: <44FEE7A8.1050904@garzik.org>
References: <200609041237.46528.ossthema@de.ibm.com> <20060904201606.GA24386@electric-eye.fr.zoreil.com> <200609042311.21202.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32731 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751443AbWIFPWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 11:22:22 -0400
To: Arnd Bergmann <arnd@arndb.de>
In-Reply-To: <200609042311.21202.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> Am Monday 04 September 2006 22:16 schrieb Francois Romieu:
>>> +#include "ehea.h"
>>> +#include "ehea_qmr.h"
>>> +#include "ehea_phyp.h"
>> Afaik none of those is included in this patch nor in my 2.6.18-git tree.
> 
> 
> They are in 5, 3 and 2, respectively
> 
>> Happy bissect in sight.
> 
> The driver should get merged as a single commit anyway, even
> if split diffs are posted for review. Even if it gets merged
> like this, bisect will work since the Kconfig option is added
> in the final patch.

That's impossible, in the form they were submitted...


