From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000e: Fix header includes
Date: Thu, 09 Aug 2007 16:15:11 -0700
Message-ID: <46BB9FFF.3080508@intel.com>
References: <20070808231525.27519.93728.stgit@localhost.localdomain> <46BB9DEA.9060406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	john.ronciak@intel.com
To: Chuck Ebbert <cebbert@redhat.com>, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18795 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754201AbXHIXPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 19:15:14 -0400
In-Reply-To: <46BB9DEA.9060406@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert wrote:
> On 08/08/2007 07:15 PM, Auke Kok wrote:
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> ---
>>
>>  drivers/net/e1000e/82571.c   |    4 ++++
>>  drivers/net/e1000e/e1000.h   |    7 ++++---
>>  drivers/net/e1000e/es2lan.c  |    5 +++++
>>  drivers/net/e1000e/ethtool.c |    3 ++-
>>  drivers/net/e1000e/hw.h      |    2 ++
>>  drivers/net/e1000e/ich8lan.c |    5 +++++
>>  drivers/net/e1000e/lib.c     |    2 ++
>>  drivers/net/e1000e/netdev.c  |    1 +
>>  8 files changed, 25 insertions(+), 4 deletions(-)
>>
> 
> Still broken on ppc:
> 
> drivers/net/e1000e/phy.c: In function 'e1000e_copper_link_setup_igp':
> drivers/net/e1000e/phy.c:512: error: implicit declaration of function 'msleep'
> drivers/net/e1000e/phy.c: In function 'e1000e_phy_has_link_generic':
> drivers/net/e1000e/phy.c:1339: error: implicit declaration of function 'mdelay'


ok, time to install git manually on my 4-year-old yellowdog ppc install :@

I'll resend a new patch to Jeff once I have this sorted out.


Auke
