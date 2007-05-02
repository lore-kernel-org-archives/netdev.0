From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v2] gianfar: Add I/O barriers when touching buffer descriptor
 ownership.
Date: Wed, 02 May 2007 15:12:52 -0500
Message-ID: <4638F0C4.2000406@freescale.com>
References: <20070502195712.GA16541@ld0162-tx32.am.freescale.net> <F1B250DD-A472-470F-B3D0-EBB2F042E454@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:42280 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1766920AbXEBUND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 16:13:03 -0400
In-Reply-To: <F1B250DD-A472-470F-B3D0-EBB2F042E454@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> I'd rather see a wmb() instead of eieio() to keep this code non-ppc  
> specific.  (also, we implement wmb as eieio, so I don't keep the  
> comment about it being too heavy, unless you mean generically).

wmb() is a sync, smp_wmb() is an eieio.  Andy told me he would not 
accept a sync in those spots.

And the driver is already ppc-specific; it uses in/out_be32.

-Scott
