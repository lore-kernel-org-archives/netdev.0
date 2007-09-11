From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Configurable tap interface MTU
Date: Tue, 11 Sep 2007 10:20:53 -0700
Message-ID: <46E6CE75.5040700@hp.com>
References: <e6c711510709110742v4d2da644ha63b0a6d47c1230b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maxk@qualcomm.com,
	linux-kernel@vger.kernel.org
To: Ed Swierk <eswierk@arastra.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:52168 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbXIKRVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 13:21:20 -0400
In-Reply-To: <e6c711510709110742v4d2da644ha63b0a6d47c1230b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ed Swierk wrote:
> This patch makes it possible to change the MTU on a tap interface.
> Increasing the MTU beyond the 1500-byte default is useful for
> applications that interoperate with Ethernet devices supporting jumbo
> frames.
> 
> The patch caps the MTU somewhat arbitrarily at 16000 bytes. This is
> slightly lower than the value used by the e1000 driver, so it seems
> like a safe upper limit.

FWIW the OFED 1.2 bits take the MTU of IPoIB up to 65520 bytes :)

rick jones
