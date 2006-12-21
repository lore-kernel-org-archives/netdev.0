From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 2/10] cxgb3 - main source file
Date: Thu, 21 Dec 2006 09:16:18 +0100
Message-ID: <1166688978.3365.1472.camel@laptopd505.fenrus.org>
References: <20061220124134.6299.29373.stgit@localhost.localdomain>
	 <1166623330.3365.1397.camel@laptopd505.fenrus.org>
	 <4589CA9C.80007@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <None@chelsio.com>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:35660 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422839AbWLUIQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 03:16:32 -0500
To: Divy Le Ray <divy@chelsio.com>
In-Reply-To: <4589CA9C.80007@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> They are used to parameter the HW:
> register access,

ethtool supports that, so shouldn't be an ioctl for sure

>  configuration of queue sets, on board memory 
> configuration,

I'm sure ethtool can do that too

> firmware load, etc ...

and for this we have request_firmware() interface. 

adding device specific ioctl that duplicate functionality that exists or
should exist in a generic way isn't really acceptable for 2.6 kernels
anymore....



-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

