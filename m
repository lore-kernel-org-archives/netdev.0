From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH net-next 4/8] mv88e6xxx: Combine mv88e6131 and
 mv88e612_61_65 drivers
Date: Sun, 27 Nov 2011 20:18:38 +0100
Message-ID: <20111127191838.GT795@wantstofly.org>
References: <1322267572.2839.381.camel@deadeye>
 <1322267779.2839.385.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:65485 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994Ab1K0TSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 14:18:40 -0500
Content-Disposition: inline
In-Reply-To: <1322267779.2839.385.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 26, 2011 at 12:36:19AM +0000, Ben Hutchings wrote:

> These drivers share a lot of code, so if we make them modular they
> should be built into the same module.  Therefore, link them together
> and merge their respective module init and exit functions.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>

Minor nit: s/612_/6123_/ in Subject: line.


> ---
>  net/dsa/Makefile          |    7 ++++---
>  net/dsa/mv88e6123_61_65.c |   15 +--------------
>  net/dsa/mv88e6131.c       |   15 +--------------
>  net/dsa/mv88e6xxx.c       |   23 +++++++++++++++++++++++
>  net/dsa/mv88e6xxx.h       |    3 +++
>  5 files changed, 32 insertions(+), 31 deletions(-)

[...]
