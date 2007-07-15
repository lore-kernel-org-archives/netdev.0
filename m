From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/3] lro: Generic Large Receive Offload for TCP traffic
Date: Sat, 14 Jul 2007 23:57:48 -0700 (PDT)
Message-ID: <20070714.235748.02297780.davem@davemloft.net>
References: <200707111621.24852.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raisch@de.ibm.com, themann@de.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	meder@de.ibm.com, tklein@de.ibm.com, stefan.roscher@de.ibm.com
To: ossthema@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55404
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752105AbXGOG5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 02:57:46 -0400
In-Reply-To: <200707111621.24852.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I think this work is great.  Thanks for doing it.

Besides the fixups Evgeniy has selected, and the suggestion
to receive into pages to cut down allocation costs, my
only request is to make this thing able to handle ipv6 as
well even if no current chips could facilitate that yet.
