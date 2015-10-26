From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [Intel-wired-lan] [PATCH net-next 0/4] Automatic adjustment of
 max frame size
Date: Mon, 26 Oct 2015 10:09:46 +0900
Message-ID: <562D7D5A.6050400@lab.ntt.co.jp>
References: <20151023044604.GA5024@aiaiai.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	intel-wired-lan@lists.osuosl.org, Patrick McHardy <kaber@trash.net>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:38109 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752364AbbJZBKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 21:10:00 -0400
In-Reply-To: <20151023044604.GA5024@aiaiai.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/10/23 13:46, ND Linux CI Server wrote:
...
> checkpatch.pl has some complaints:
> 
> --------------------------------------------------------------------------------
> 
> checkpatch.pl results for patch "[PATCH 2/4] e1000e: Add ndo_enc_hdr_len"
> 
> WARNING:LONG_LINE: line over 80 characters
> #53: FILE: drivers/net/ethernet/intel/e1000e/netdev.c:3981:
> +		if (adapter->max_frame_size > VLAN_ETH_FRAME_LEN + ETH_FCS_LEN) {
> 
> WARNING:LONG_LINE: line over 80 characters
> #62: FILE: drivers/net/ethernet/intel/e1000e/netdev.c:4000:
> +		if (adapter->max_frame_size > VLAN_ETH_FRAME_LEN + ETH_FCS_LEN) {
> 
> WARNING:LONG_LINE: line over 80 characters
> #71: FILE: drivers/net/ethernet/intel/e1000e/netdev.c:4014:
> +		if (adapter->max_frame_size <= VLAN_ETH_FRAME_LEN + ETH_FCS_LEN) {
> 
> total: 0 errors, 3 warnings, 0 checks, 184 lines checked

I was aware of these warnings but my understanding was that lines
without over 80 characters are not mandatory requirement and a short
overrun can be acceptable, like 81 or 82... Not sure what made me think
so, though.

Anyway, I will fix these warnings.

Thanks,
Toshiaki Makita
