From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH iproute2] Install the bridge command under the same name
 we build it.
Date: Mon, 06 Aug 2012 09:51:13 +0800
Message-ID: <501F2311.8070708@cn.fujitsu.com>
References: <87ehnmiv1m.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Nick Alcock <nick.alcock@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36958 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755286Ab2HFBwB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Aug 2012 21:52:01 -0400
In-Reply-To: <87ehnmiv1m.fsf@spindle.srvr.nix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/2012 10:36 PM, Nick Alcock wrote:
> 
> Signed-off-by: Nick Alcock <nick.alcock@oracle.com>
> ---
>  bridge/Makefile | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/bridge/Makefile b/bridge/Makefile
> index 0c333bf..9a6743e 100644
> --- a/bridge/Makefile
> +++ b/bridge/Makefile
> @@ -7,8 +7,8 @@ all: bridge
>  bridge: $(BROBJ) $(LIBNETLINK) 
>  
>  install: all
> -	install -m 0755 br $(DESTDIR)$(SBINDIR)
> +	install -m 0755 bridge $(DESTDIR)$(SBINDIR)
>  
>  clean:
> -	rm -f $(BROBJ) br
> +	rm -f $(BROBJ) bridge
>  

Hi Nick,

To post a patch for iproute2, you should send it to 
Stephen Hemminger <shemminger@vyatta.com> who is the maintainer of iproute2.


Stephen, I also noticed this problem and thought should ask you for the final
name of the brige extension. Personally I prefer br, it is short and
distingushable enough.

Thanks.
