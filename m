From: Paul Dickson <paul@permanentmail.com>
Subject: Re: [patch 2/2] round_jiffies users
Date: Tue, 10 Oct 2006 15:47:17 -0700
Message-ID: <20061010154717.e2c4c149.paul@permanentmail.com>
References: <1160496165.3000.308.camel@laptopd505.fenrus.org>
	<1160496210.3000.310.camel@laptopd505.fenrus.org>
	<1160496263.3000.312.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, akpm@osdl.org, mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from rune.pobox.com ([208.210.124.79]:62404 "EHLO rune.pobox.com")
	by vger.kernel.org with ESMTP id S1030586AbWJJWra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2006 18:47:30 -0400
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1160496263.3000.312.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Oct 2006 18:04:23 +0200, Arjan van de Ven wrote:

> +			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));

Shouldn't round_jiffies_relative be used for some of these, a la:

  +			mod_timer(&adapter->phy_info_timer, round_jiffies_relative(2 * HZ));

	-Paul

