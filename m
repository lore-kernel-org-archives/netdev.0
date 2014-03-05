From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] sfc: Use ether_addr_copy and eth_broadcast_addr
Date: Wed, 05 Mar 2014 09:10:19 -0800
Message-ID: <1394039419.3271.75.camel@joe-AO722>
References: <alpine.LFD.2.03.1403041449370.13034@solarflare.com>
	 <20140304.153653.263004778768283059.davem@davemloft.net>
	 <53170EF5.1030809@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	sshah@solarflare.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0222.hostedemail.com ([216.40.44.222]:53174 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752623AbaCERKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 12:10:23 -0500
In-Reply-To: <53170EF5.1030809@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-05 at 11:48 +0000, Edward Cree wrote:
> On 04/03/14 20:36, David Miller wrote:
> >> diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
[]
> >> @@ -162,8 +162,8 @@ static int efx_ef10_get_mac_address(struct efx_nic *efx, u8 *mac_address)
[]
> >> -	memcpy(mac_address,
> >> -	       MCDI_PTR(outbuf, GET_MAC_ADDRESSES_OUT_MAC_ADDR_BASE), ETH_ALEN);
> >> +	ether_addr_copy(mac_address,
> >> +	       MCDI_PTR(outbuf, GET_MAC_ADDRESSES_OUT_MAC_ADDR_BASE));
> > This is not indented correctly, the original code was.
> Oops, yes.
> After fixing that, checkpatch also complains about a couple of long
> lines (mcdi.c:1207-8).  Am I right in thinking that it's being
> overzealous and is best ignored in this case?

Dunno if it's being overzealous, but anywhere overly
long variable names exist, (36+ chars here), wrapping to
80 columns is a bit limited.

Anyway, I wouldn't consider those long lines a problem.
