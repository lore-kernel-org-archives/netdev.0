From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 1/1] net: mv643xx_eth: Make TSO disabled by default
Date: Sat, 1 Nov 2014 18:00:37 +0100
Message-ID: <20141101180037.087b7a95@free-electrons.com>
References: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<1414855820-15094-2-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:46994 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752464AbaKARAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 13:00:40 -0400
In-Reply-To: <1414855820-15094-2-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Ezequiel Garcia,

On Sat,  1 Nov 2014 12:30:20 -0300, Ezequiel Garcia wrote:
> Data corruption has been observed to be produced by TSO. For instance,
> accessing files on a NFS-server with TSO enabled results in different data
> transferred each time.
> 
> This has been observed only on Kirkwood platforms, i.e. with the mv643xx_eth
> driver. Same tests on platforms using the mvneta ethernet driver have
> passed without errors.
> 
> Make TSO disabled by default for now, until we can found a proper fix
> for the regression.
> 
> Fixes: 3ae8f4e0b98 ('net: mv643xx_eth: Implement software TSO')
> Reported-by: Slawomir Gajzner <slawomir.gajzner@gmail.com>
> Reported-by: Julien D'Ascenzio <jdascenzio@yahoo.fr>
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>

Shouldn't you have a:

   Cc: <stable@vger.kernel.org> # v3.16+

here ?

Thanks,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
