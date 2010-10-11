From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1c: Add support for Atheros AR8152 and AR8152
Date: Sun, 10 Oct 2010 21:03:04 -0700 (PDT)
Message-ID: <20101010.210304.71107535.davem@davemloft.net>
References: <1286759930.2955.285.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lrodriguez@atheros.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44822
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750713Ab0JKECn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 00:02:43 -0400
In-Reply-To: <1286759930.2955.285.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 11 Oct 2010 02:18:50 +0100

> Your commit 496c185c9495629ef1c65387cb2594578393cfe0 "atl1c: Add support
> for Atheros AR8152 and AR8152" included the following changes:
 ...
>> +		if (hw->nic_type == athr_l1c || hw->nic_type == athr_l2c_b) {
 ...
>> +	if ((hw->nic_type == athr_l1c || hw->nic_type == athr_l2c)) {
 ...
> Shouldn't the first if-statement use the same condition as the second
> i.e. matching the previously-defined hardware types athr_l1c and
> athr_l2c?

Yeah that definitely looks like a bug to me.
