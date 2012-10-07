From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: skge: Add DMA mask quirk for Marvell 88E8001 on ASUS P5NSLI motherboard.
Date: Sun, 07 Oct 2012 11:32:53 +0200
Message-ID: <50714C45.3080103@computer.org>
References: <50711961.1010101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Graham Gower <graham.gower@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay002.isp.belgacom.be ([195.238.6.175]:17620 "EHLO
	mailrelay002.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750967Ab2JGJfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 05:35:15 -0400
In-Reply-To: <50711961.1010101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2012 07:55 AM, Graham Gower wrote:
> Signed-off-by: Graham Gower <graham.gower@gmail.com>
> 
> --- skge.c.bak    2012-10-07 13:00:56.000000000 +1030
> +++ skge.c    2012-10-07 13:26:03.000000000 +1030
> @@ -4143,6 +4143,13 @@

Graham,

Your patch should include the path to the file being patched relative to
the base directory. So in this case something like

--- a/drivers/net/ethernet/marvell/skge.c ...
+++ b/drivers/net/ethernet/marvell/skge.c ...

HTH, Jan
