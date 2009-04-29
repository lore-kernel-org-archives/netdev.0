From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next-2.6] pcnet32: Remove pointless memory barriers
Date: Thu, 30 Apr 2009 00:29:06 +0200
Message-ID: <20090429222906.GA16498@electric-eye.fr.zoreil.com>
References: <1240945659.8819.9.camel@Maple> <20090428.221605.71993506.davem@davemloft.net> <1241012897.7487.12.camel@Maple> <1241025057.17018.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Dykstra <john.dykstra1@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeff@garzik.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34952 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762113AbZD2W3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 18:29:53 -0400
Content-Disposition: inline
In-Reply-To: <1241025057.17018.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don Fry <pcnet32@verizon.net> :
> My original NAPI implementation did not have the mmiowb() but it was
> added because of some comments from Francois Romeiu (2006-06-29/30).  I
> do not know if they are required or not.  My feeling was/is that they
> are not as the writes are flushed with the unlocking primitives.
> However that is not based on knowledge, just "feeling".

(not sure if anyone should care about the loss of performance on x86
for a memory barrier near a couple of PCI I/O accesses but...)

I take back my comment from 2006 as I did not notice that there were
PCI I/O space accesses only.

-- 
Ueimor
