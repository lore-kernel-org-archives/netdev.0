From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH RESEND] 2.[46]: Permit the official ARP hw type in
 SIOCSARP for FDDI
Date: Tue, 5 Oct 2004 12:54:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005125433.3cc516c9.davem@davemloft.net>
References: <Pine.LNX.4.58L.0410040312500.22545@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Maciej W. Rozycki" <macro@linux-mips.org>
In-Reply-To: <Pine.LNX.4.58L.0410040312500.22545@blysk.ds.pg.gda.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Oct 2004 23:57:09 +0100 (BST)
"Maciej W. Rozycki" <macro@linux-mips.org> wrote:

>  The SIOCSARP handling code currently rejects attempts of setting an arp
> entry for FDDI devices if the Ethernet ARP hw type is specified in the
> request.  Using this ARP hw type is mandated by RFC 1390 (STD 36) and I
> think it's reasonable to accept SIOCSARP requests using this type,
> especially as it already works this way for ARP packets received from the
> network.  One reason for this is bootpd setting explicit ARP cache entries
> using the hw type that is also sent to a client.  Here is a patch for both
> 2.4 and 2.6 that fixes the problem for me.  For consistency with code used
> for ARP packets, it makes both Ethernet and IEEE802 ARP hw type acceptable
> for FDDI interfaces.  Please apply.
> 
>  Applies both to 2.4.27 and to 2.6.8.1.

Patch applied, thanks.
