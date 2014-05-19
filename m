From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH net-next 3/4] Documentation: devicetree: add old and
 deprecated 'fixed-link'
Date: Mon, 19 May 2014 22:22:48 +0200
Message-ID: <20140519222248.5694cf62@free-electrons.com>
References: <1400528625-32744-1-git-send-email-f.fainelli@gmail.com>
	<1400528625-32744-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	devicetree@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:54830 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932478AbaESUWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 16:22:51 -0400
In-Reply-To: <1400528625-32744-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Florian Fainelli,

On Mon, 19 May 2014 12:43:44 -0700, Florian Fainelli wrote:
> Update the fixed-link Device Tree binding documentation to contain
> information about the old and deprecated 5-digit 'fixed-link' property.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  Documentation/devicetree/bindings/net/fixed-link.txt | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
> index e956de1be935..a87e28b68dee 100644
> --- a/Documentation/devicetree/bindings/net/fixed-link.txt
> +++ b/Documentation/devicetree/bindings/net/fixed-link.txt
> @@ -18,6 +18,13 @@ properties:
>  * 'asym-pause' (boolean, optional), to indicate that asym_pause should
>    be enabled.
>  
> +Old, deprecated 'fixed-link' binding:
> +
> +* 'fixed-link' : <a b c d e> where a is emulated phy id - choose any,
> +  but unique to the all specified fixed-links, b is duplex - 0 half,
> +  1 full, c is link speed - d#10/d#100/d#1000, d is pause - 0 no
> +  pause, 1 pause, e is asym_pause - 0 no asym_pause, 1 asym_pause.

I know it's copy/pasted from a previous binding document, but I find
the explanation here rather difficult to read, especially the
d#10/d#100/d#1000 thing. Could we have something more readable, like:

 * A 'fixed-link' property in the Ethernet MAC node, with 5 cells, of
   the form <a b c d e>:
   - a: emulated phy id, choose any but unique to all specified
     fixed-links
   - b: duplex configuration: 0 for half duplex, 1 for full duplex
   - c: link speed in Mbit/s, accepted values are: 10, 100 and 1000
   - d: pause configuration: 0 for no pause, 1 for pause
   - e: asym_pause configuration: 0 for no asym_pause, 1 for asym_pause

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
