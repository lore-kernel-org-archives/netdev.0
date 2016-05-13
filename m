From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] geneve: fix IPv6 remote address reporting
Date: Fri, 13 May 2016 14:43:18 -0700
Message-ID: <20160513144318.32dcb51c@xeon-e3>
References: <572CAA09.302@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34871 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056AbcEMVnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 17:43:07 -0400
Received: by mail-pf0-f171.google.com with SMTP id 77so46088906pfv.2
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 14:43:07 -0700 (PDT)
In-Reply-To: <572CAA09.302@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 May 2016 15:28:25 +0100
Edward Cree <ecree@solarflare.com> wrote:

> Since we can only configure unicast, we probably want to be able to
> display unicast, rather than multicast.
> 
> Fixes: 906ac5437ab8 ("geneve: add support for IPv6 link partners")
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
> I'm assuming this is what was intended, but tbh I don't know why we
> need to check for multicast on the display side at all, rather than
> just displaying whatever the kernel gives us.
> 
>  ip/iplink_geneve.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Applied thanks
