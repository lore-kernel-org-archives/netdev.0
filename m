From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v1 4/7] amd-xgbe: Move the PHY support into amd-xgbe
Date: Tue, 12 May 2015 15:19:55 -0700
Message-ID: <55527C8B.1040105@gmail.com>
References: <20150512192229.14091.34354.stgit@tlendack-t1.amdoffice.net> <20150512192254.14091.4167.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Tom Lendacky <thomas.lendacky@amd.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34800 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753915AbbELWUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 18:20:16 -0400
Received: by pdbqa5 with SMTP id qa5so28986076pdb.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 15:20:16 -0700 (PDT)
In-Reply-To: <20150512192254.14091.4167.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/15 12:22, Tom Lendacky wrote:
> The AMD XGBE device is intended to work with a specific integrated PHY
> and that PHY is not meant to be a standalone PHY for use by other
> devices. As such this patch removes the phylib driver and implements
> the PHY support in the amd-xgbe driver (the majority of the logic from
> the phylib driver is moved into the amd-xgbe driver).

Did not you submit a similar patch a while ago and David asked to keep
the PHY driver separate? Even though the internal PHY driver might not
be reusable on another platform, having your Ethernet driver implement a
PHY library driver seems like a potential layering issue.
-- 
Florian
