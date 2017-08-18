From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v1 05/14] amd-xgbe: Add additional debugfs
 support
Date: Fri, 18 Aug 2017 02:30:57 +0200
Message-ID: <20170818003057.GA11030@lunn.ch>
References: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
 <20170818000250.10005.87855.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34168 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752872AbdHRAbB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 20:31:01 -0400
Content-Disposition: inline
In-Reply-To: <20170818000250.10005.87855.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 07:02:50PM -0500, Tom Lendacky wrote:
> Add additional debugfs support for reading / writing registers of any
> attached external phy devices as well as the SFP eeprom data.

Hi Tom

What is wrong with using the standard APIs for this?

ethtool --moduile-info

ioctls SIOCGMIIREG and SIOCSMIIREG.

	Andrew
