From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v2] gianfar: Add I/O barriers when touching buffer descriptor
 ownership.
Date: Wed, 02 May 2007 16:30:19 -0500
Message-ID: <463902EB.8070401@freescale.com>
References: <20070502195712.GA16541@ld0162-tx32.am.freescale.net> <F1B250DD-A472-470F-B3D0-EBB2F042E454@kernel.crashing.org> <4638F0C4.2000406@freescale.com> <FA9554A4-5A7D-4E03-BE28-C4B6B80D9DB9@kernel.crashing.org> <4638F734.2040809@freescale.com> <41B347BE-06AA-4346-BEFB-19DFB52AC533@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:50935 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767030AbXEBVag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 17:30:36 -0400
In-Reply-To: <41B347BE-06AA-4346-BEFB-19DFB52AC533@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> Why doesn't marking the bdp pointer volatile resolve the issue in  
> gfar_clean_rx_ring() to ensure load ordering?

Because that only addresses compiler reordering (and does so in a rather 
clumsy way -- not all accesses need to be strongly ordered), not 
hardware reordering.

-Scott
