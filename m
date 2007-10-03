From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: jumbo frame regression fix
Date: Wed, 03 Oct 2007 13:39:50 -0400
Message-ID: <4703D3E6.4080003@pobox.com>
References: <1191372129.26233.12.camel@localhost> <20071002180209.47c350a3@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pomac@vapor.com, Linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755390AbXJCRkT@vger.kernel.org>
In-Reply-To: <20071002180209.47c350a3@freepuppy.rosehill>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Remove unneeded check that caused problems with jumbo frame sizes.
> The check was recently added and is wrong.
> When using jumbo frames the sky2 driver does fragmentation, so
> rx_data_size is less than mtu.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied
