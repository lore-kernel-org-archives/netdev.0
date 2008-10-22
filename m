From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] pci: use pci_ioremap_bar() in drivers/net
Date: Wed, 22 Oct 2008 06:50:10 -0700
Message-ID: <20081022065010.53b27680@infradead.org>
References: <20081020214239.398f1838@infradead.org>
	<a15869500810220005h76149fd1w5d325ff18659fa74@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Eliezer Tamir" <eliezer.tamir@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54396 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbYJVNuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 09:50:04 -0400
In-Reply-To: <a15869500810220005h76149fd1w5d325ff18659fa74@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Oct 2008 09:05:20 +0200
"Eliezer Tamir" <eliezer.tamir@gmail.com> wrote:

> BNX2X devices have two BARs.
> You might want to convert both.

the second one doesn't map the whole bar per se... so it doesn't fit
the pattern of pci_ioremap_bar()

-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
