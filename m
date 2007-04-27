From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] ipv6: track device renames in snmp6
Date: Thu, 26 Apr 2007 21:16:59 -0700
Message-ID: <20070427041659.GB4841@kroah.com>
References: <20070426164247.3b3b2c7a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ???????????? <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:42603 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288AbXD0EYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 00:24:47 -0400
Content-Disposition: inline
In-Reply-To: <20070426164247.3b3b2c7a@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2007 at 04:42:47PM -0700, Stephen Hemminger wrote:
> When network device's are renamed, the IPV6 snmp6 code
> gets confused. It doesn't track name changes so it will OOPS
> when network device's are removed.
> 
> The fix is trivial, just unregister/re-register in notify handler.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Which -stable is this for, 2.6.20 or 2.6.21?

thanks,

greg k-h
