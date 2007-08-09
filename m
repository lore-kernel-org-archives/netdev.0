From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Wed, 08 Aug 2007 21:23:53 -0700 (PDT)
Message-ID: <20070808.212353.105403708.davem@davemloft.net>
References: <OFA2F18805.38AA0BD0-ON87257331.005367FB-88257331.0027BEED@us.ibm.com>
	<1186587154.5155.43.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xma@us.ibm.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, rdreier@cisco.com,
	rusty@rustcorp.com.au, shemminger@linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52185
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751585AbXHIEXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 00:23:54 -0400
In-Reply-To: <1186587154.5155.43.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 08 Aug 2007 11:32:34 -0400

> Think of a box where you have other network interfaces, the way you
> are implementing currently implies you are going to be very unfair to 
> the other interfaces on the box. 

This was the point I was trying to make the other day.

What's good for the goose (ipoib) is not necessarily good for the
gander and NAPI exists for the gander as much as for the goose.
