From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 05/14] amd-xgbe: Add additional debugfs
 support
Date: Thu, 17 Aug 2017 22:02:03 -0700 (PDT)
Message-ID: <20170817.220203.1607309698344574831.davem@davemloft.net>
References: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
        <20170818000250.10005.87855.stgit@tlendack-t1.amdoffice.net>
        <20170818003057.GA11030@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44066 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbdHRFCE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 01:02:04 -0400
In-Reply-To: <20170818003057.GA11030@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri, 18 Aug 2017 02:30:57 +0200

> On Thu, Aug 17, 2017 at 07:02:50PM -0500, Tom Lendacky wrote:
>> Add additional debugfs support for reading / writing registers of any
>> attached external phy devices as well as the SFP eeprom data.
> 
> Hi Tom
> 
> What is wrong with using the standard APIs for this?
> 
> ethtool --moduile-info
> 
> ioctls SIOCGMIIREG and SIOCSMIIREG.

Yeah debugfs is a horrible choice for this.

debugfs in general should be strongly avoided.  We have rich eneough
facilities to export just about anything that is actually appropriate
and useful, and where we do not existing facilities should be extended
as needed rather than ignored.
