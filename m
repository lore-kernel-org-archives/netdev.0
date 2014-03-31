From: Neil Jerram <Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org>
Subject: Re: [patch net-next RFC v2 4/6] net: introduce switchdev
	API
Date: Mon, 31 Mar 2014 20:47:27 +0000
Message-ID: <F6885DC5CBE92C4BB4D654841E63A30FD7DFC91C@ENFIRHMBX1.datcon.co.uk>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <1395851472-10524-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 "andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org" <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
 "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 "f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 "jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 "ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org" <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
 "roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org" <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 "jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org" <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
 "linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 "vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 "sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org" <sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 "stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
 "dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: 'Jiri Pirko' <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
 <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1395851472-10524-5-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

> diff --git a/net/Kconfig b/net/Kconfig
> index e411046..e02ab8d 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -285,6 +285,16 @@ config NET_FLOW_LIMIT
>  	  with many clients some protection against DoS by a single (spoofed)
>  	  flow that greatly exceeds average workload.
> 
> +config NET_SWITCHDEV
> +	tristate "Switch device"
> +	depends on INET
> +	---help---
> +	  This module provides glue for hardware switch chips so they can be
> +	  accessed from userspace via Open vSwitch Netlink API.
> +
> +	  To compile this code as a module, choose M here: the
> +	  module will be called pktgen.
> +

"pktgen" cut'n'paste typo.

	Neil
