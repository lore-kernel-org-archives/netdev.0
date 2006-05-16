From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [1/1] netchannel subsystem.
Date: Tue, 16 May 2006 00:06:31 -0700 (PDT)
Message-ID: <20060516.000631.12029052.davem@davemloft.net>
References: <20060516061909.GA28670@2ka.mipt.ru>
	<20060515.235712.26771832.davem@davemloft.net>
	<20060516065923.GA8649@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kelly@au1.ibm.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29661
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751636AbWEPHLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 03:11:25 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060516065923.GA8649@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 16 May 2006 10:59:23 +0400

> And what if we use ESP which would place it's hashed sequence number as
> port?

If it makes you happy put something like:

	case TCP:
	case UDP:
	case SCTP:
	case DCCP:
	     ...

	default:
	     ...
