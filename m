From: David Miller <davem@davemloft.net>
Subject: Re: Internet-Draft on Port Randomisation
Date: Tue, 09 Sep 2008 13:04:24 -0700 (PDT)
Message-ID: <20080909.130424.170861701.davem@davemloft.net>
References: <28fa9c5e0809082107p7a33dc4fod344fde212e1d710@mail.gmail.com>
	<48C60284.2070402@vyatta.com>
	<878wu1tmup.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, eugeneteo@kernel.sg,
	netdev@vger.kernel.org, eteo@redhat.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51749
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755059AbYIIUEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 16:04:30 -0400
In-Reply-To: <878wu1tmup.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 09 Sep 2008 16:28:30 +0200

> [haven't read the draft] But you don't necessarily need a full global
> lock for such a scheme. What works too is to access global state only
> ever N accesses and pre-allocate a small range per CPU. While there's
> still some global overhead then, it happens significantly less. My old
> alternative ipid setup algorithm worked this way.

Should work well on a 64K cpu system.
