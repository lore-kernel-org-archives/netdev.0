From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH net-next-2.6] pcnet32: Remove pointless memory barriers
Date: Wed, 29 Apr 2009 19:16:23 -0500
Message-ID: <1241050583.27131.82.camel@merlyn>
References: <1240945659.8819.9.camel@Maple>
	 <1241050188.18295.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, romieu@fr.zoreil.com,
	David Miller <davem@davemloft.net>
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:47736 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbZD3AQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 20:16:34 -0400
Received: by yx-out-2324.google.com with SMTP id 3so878463yxj.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2009 17:16:33 -0700 (PDT)
In-Reply-To: <1241050188.18295.13.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-04-29 at 17:09 -0700, Don Fry wrote:
> After going back to my original NAPI changes, email exchanges today
> with
> Francois and John, and looking through all the architecture
> implementation of mmiowb and locking; I agree that this mmiowb is
> unnecessary since a lock is always released which has all the memory
> barriers needed.

[Off-list]

Don, I didn't mean to create this additional work for you, but I very
much appreciate the help.

  --  John

