From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 02 Jun 2010 10:12:58 -0700 (PDT)
Message-ID: <20100602.101258.134121018.davem@davemloft.net>
References: <alpine.DEB.2.00.1006021126500.30182@router.home>
	<1275496439.2725.203.camel@edumazet-laptop>
	<alpine.DEB.2.00.1006021140320.30182@router.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58100
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758225Ab0FBRMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 13:12:48 -0400
In-Reply-To: <alpine.DEB.2.00.1006021140320.30182@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 2 Jun 2010 11:49:18 -0500 (CDT)

> On Wed, 2 Jun 2010, Eric Dumazet wrote:
> 
>> take a look at
>>
>> http://www.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/html/SystemTap_Beginners_Guide/useful-systemtap-scripts.html#dropwatch
> 
> System tap?

You don't need to use system tap, just the normal tracing stuff using
sysfs files suffices.

