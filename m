From: David Miller <davem@davemloft.net>
Subject: Re: using huge numbers of queues
Date: Wed, 07 Oct 2009 15:38:11 -0700 (PDT)
Message-ID: <20091007.153811.139592035.davem@davemloft.net>
References: <c0a09e5c0910071459r2768f420lae87f7404dfbc054@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: andy.grover@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50386
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755111AbZJGWiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 18:38:16 -0400
In-Reply-To: <c0a09e5c0910071459r2768f420lae87f7404dfbc054@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Grover <andy.grover@gmail.com>
Date: Wed, 7 Oct 2009 14:59:49 -0700

> At NetConf, you made a passing remark about wanting lots of queues,
> even 1-per-socket. Have you thought further about how we would use so
> many?

Classification.

Lots and lots of virtual queues, which map to a smaller number
of physical queues for delivery.

The virtual queue matched serves as a index and a classification
hint to things like GRO receive, etc.
