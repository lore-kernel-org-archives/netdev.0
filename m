From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next]alx: Atheros AR8131/AR8151/AR8152/AR8161
 Ethernet driver
Date: Thu, 20 Oct 2011 04:48:43 -0400 (EDT)
Message-ID: <20111020.044843.1562615208158270555.davem@davemloft.net>
References: <1319009213-20627-1-git-send-email-cloud.ren@atheros.com>
	<20111019222140.GA9937@electric-eye.fr.zoreil.com>
	<6349D7A510622448B1BA0967850A8438011CC12D@nasanexd02d.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, rodrigue@qca.qualcomm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cjren@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6349D7A510622448B1BA0967850A8438011CC12D@nasanexd02d.na.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ren, Cloud" <cjren@qca.qualcomm.com>
Date: Thu, 20 Oct 2011 07:29:27 +0000

> Thanks for your information.
> 
> Drivers on different OSs share alf_hw.c, alf_hw.h, alc_hw.c and alc_hw.h
> 
> So it looks some of codes are duplicate, because other drivers need them.

You cannot do this, you must get rid of such compatability wrappers
and unused code.
