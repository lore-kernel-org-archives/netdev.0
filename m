From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Netchannel subsystem update.
Date: Sun, 21 May 2006 23:06:17 -0700 (PDT)
Message-ID: <20060521.230617.64626468.davem@davemloft.net>
References: <20060516173416.GA22552@2ka.mipt.ru>
	<20060518103443.GB26183@2ka.mipt.ru>
	<20060520155202.GA31923@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kelly@au1.ibm.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52945
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932429AbWEVGG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 May 2006 02:06:29 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060520155202.GA31923@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Sat, 20 May 2006 19:52:02 +0400

> While developing first apporoach I've found that input TCP processing 
> sometimes refers to dst_entry which can only be obtained through the input
> routing code. You can find appropriate changes in attached incremental patch.

It would be no trouble to cache the input route in the socket
when netchannel is enabled.
