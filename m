From: David Miller <davem@davemloft.net>
Subject: Re: [patch sungem] improved locking
Date: Mon, 13 Nov 2006 23:44:56 -0800 (PST)
Message-ID: <20061113.234456.78492515.davem@davemloft.net>
References: <5cac192f0611121511w6a8fec54pdf6124b5f2f79a08@mail.gmail.com>
	<20061113.164622.28395064.davem@davemloft.net>
	<5cac192f0611132328i52d6d615g28d8c493dc028621@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29579
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933211AbWKNHoq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 02:44:46 -0500
To: eric.lemoine@gmail.com
In-Reply-To: <5cac192f0611132328i52d6d615g28d8c493dc028621@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric Lemoine" <eric.lemoine@gmail.com>
Date: Tue, 14 Nov 2006 08:28:42 +0100

> because it makes it explicit that only bits 0 through 6 are taken into
> account when writing the IACK register.

The phrase "bits 0 through 6" doesn't make any sense when bit 3 DOES
NOT EXIST in the hardware, it's reserved, it's not there, so including
it only confuses people and obfuscates the code.

Please use the explicit bit mask composed of existing macros, which
not only makes sure that the mask has meaning, but it also makes sure
that reserved and non-existing bits are never referenced.
