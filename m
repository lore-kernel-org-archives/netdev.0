From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.27.7-9-pae #7 SMP 1/1] networking tcp: Writing tcp
 socket be atomic
Date: Wed, 03 Feb 2010 08:52:49 -0800 (PST)
Message-ID: <20100203.085249.98326242.davem@davemloft.net>
References: <474C17045AA24E3F8519EE76BAB47439@JOHNYE1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org, jmorris@namei.org,
	kaber@coreworks.de, linux-kernel@vger.kernel.org
To: johny@asimco.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56392
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757291Ab0BCQwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 11:52:37 -0500
In-Reply-To: <474C17045AA24E3F8519EE76BAB47439@JOHNYE1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Locking belongs inside of the application, not in the kernel.

As evidenced by the fact that you had to add new socket options, the
application needs to be modified anyways.

It's therefore just as easy to add the appropriate locking to the
sequences where the application writes over the TCP socket.  And
it avoids having to modify the kernel at all.
