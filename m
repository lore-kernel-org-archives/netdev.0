From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: ixgbe: [RFC] [PATCH] Fix return of invalid txq
Date: Fri, 12 Feb 2010 12:12:55 -0800
Message-ID: <1266005575.2167.43.camel@localhost>
References: <1263546020.2038.7.camel@localhost>
	 <20100115.010628.67106329.davem@davemloft.net>
	 <F86E8680A7D9D74A99DC6345E35A6929501BA2CA@orsmsx503.amr.corp.intel.com>
	 <20100212.115552.166740353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "krkumar2@in.ibm.com" <krkumar2@in.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15961 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755960Ab0BLUMy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 15:12:54 -0500
In-Reply-To: <20100212.115552.166740353.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-12 at 12:55 -0700, David Miller wrote:
> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> Date: Sat, 16 Jan 2010 02:53:15 -0800
> 
> > Either way works though.  I still think the table is the better way
> > to go, because of the determinism for any system and NIC
> > configuration/layout.  The overhead of configuring the table is
> > taken during open(), so it's not in the hotpath at all.
> 
> How many minus operations can your cpu perform in the same amount
> of time it takes to access memory? :-)

Touche. :)

