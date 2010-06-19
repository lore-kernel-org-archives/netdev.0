From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/8] e1000e: cleanup ethtool loopback
 setup code
Date: Fri, 18 Jun 2010 22:15:12 -0700 (PDT)
Message-ID: <20100618.221512.102550313.davem@davemloft.net>
References: <20100616232523.4834.84849.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37620
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754871Ab0FSFPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jun 2010 01:15:01 -0400
In-Reply-To: <20100616232523.4834.84849.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've applied this series however:

1) Please address Ben's concerns about turning EEE on by default
   given that standardization is not complete yet.

2) I hate module parameters, I'd rather you create a new ethtool
   feature bit and thus allow the setting to be modified at run
   time.  Please create a new ethtool control flag, and remove
   this module option.

Thanks.
