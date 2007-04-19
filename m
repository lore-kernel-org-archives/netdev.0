From: David Miller <davem@davemloft.net>
Subject: Re: AF_PACKET how to get the original netdev from a packet
 received from a bonded master
Date: Wed, 18 Apr 2007 18:06:22 -0700 (PDT)
Message-ID: <20070418.180622.35354420.davem@davemloft.net>
References: <41b516cb0704181652o6a05b570t511ee23373a0b3ac@mail.gmail.com>
	<20070418.170749.07021824.davem@davemloft.net>
	<41b516cb0704181717l2c6c15a0j9ae275d15c6b22f4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chavey@google.com, netdev@vger.kernel.org
To: chris.leech@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55648
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030939AbXDSBGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 21:06:19 -0400
In-Reply-To: <41b516cb0704181717l2c6c15a0j9ae275d15c6b22f4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Chris Leech" <chris.leech@gmail.com>
Date: Wed, 18 Apr 2007 17:17:45 -0700

> On 4/18/07, David Miller <davem@davemloft.net> wrote:
> > Ok, it will give you one level of decapsulation.
> >
> > What do we tell people who want 2 devices previous? :-)
> 
> I can tell you that the intent of PJs patch was to provide the ifindex
> of the physical interface that a packet entered the system on,
> regardless of how many layers of encapsulation are involved.
> 
> Of course it may not actually do that ...

Ok, I'll try to remember to high-priority reviewing PJ's patch
on my next rebase of the net-2.6.22 tree which should be
tonight or tomorrow sometime.
