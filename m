From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2][NETNS] net: Modify the neighbour table code so it
 handles multiple network namespaces
Date: Thu, 20 Dec 2007 15:40:22 -0800 (PST)
Message-ID: <20071220.154022.13738739.davem@davemloft.net>
References: <20071219145544.184198087@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071219145830.605868037@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@openvz.org, benjamin.thery@bull.net,
	ebiederm@xmission.com
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41836
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750933AbXLTXkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 18:40:22 -0500
In-Reply-To: <20071219145830.605868037@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 19 Dec 2007 15:55:45 +0100

> -struct neigh_seq_state {
> +struct neigh_seq_state
> +{

Please don't make coding style change like this.

The accepted convention is:

struct NAME {
	...
};

I know the other structs in that header file use the lousy:

struct NAME
{
};

format, but that doesn't make it right and we gain nothing
by taking a step backwards instead of fixing all the instances
in that header file over to the correct style.
