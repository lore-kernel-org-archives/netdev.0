From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]NET:PCNET32: poll method return 0 when done
Date: Fri, 13 Nov 2009 19:39:43 -0800 (PST)
Message-ID: <20091113.193943.71142727.davem@davemloft.net>
References: <1257952296.1920.3.camel@myhost>
	<1258042401.7727.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: figo1802@gmail.com, netdev@vger.kernel.org
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55692
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755728AbZKNDj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 22:39:27 -0500
In-Reply-To: <1258042401.7727.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Fry <pcnet32@verizon.net>
Date: Thu, 12 Nov 2009 08:13:21 -0800

> I do not understand why you are suggesting this change.  With NAPI
> the amount of work done is returned on exit, not zero.  All other
> drivers I have looked at do not force a zero on exit.
> 
> NAK

Right, this change is completely wrong.
