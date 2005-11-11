From: "Gerd v. Egidy" <lists@egidy.de>
Subject: Re: [PATCH 00/10]: Netfilter IPsec support
Date: Fri, 11 Nov 2005 11:13:32 +0100
Message-ID: <200511111113.32591.lists@egidy.de>
References: <43740D9C.80003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org
In-Reply-To: <43740D9C.80003@trash.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Hi,

> This is the latest set patches for netfilter IPsec support.
> The use of netif_rx for the innermost SA if it used transport
> mode has been replaced by explicit NF_HOOK calls in
> xfrm{4,6}_input.c.

Could you please describe the solution you implemented a bit more? There was 
just so many back and forth that I'm confused now.

If I use it with iptables, do the transport mode packets go through INPUT and 
OUTPUT twice, decrypted and encrypted?

If I use it with iptables, do the tunnel mode packets go through FORWARD or 
INPUT and OUTPUT twice, decrypted and encrypted?

Can I do NAT in tunnel and transport mode?

what about the policy match patches, why are they only posted "for 
completeness" and as 11/12 of 10? Aren't they ready yet?

Thanks for enlightment.

Kind regards,

Gerd
