From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2.6] convert ipvs to module_param
Date: Sun, 25 Jul 2004 00:45:57 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090680357.4508.4.camel@bach>
References: <20040723131142.13081ed3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, wensong@linux-vs.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040723131142.13081ed3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-07-24 at 06:11, Stephen Hemminger wrote:
>  #ifdef CONFIG_IP_VS_DEBUG
>  static int debug=0;
> -MODULE_PARM(debug, "i");
> +module_param(debug, int, 0);
>  #endif

Sure you want 0 here?  Wouldn't it be nice to change it on the fly?

Rusty.
-- 
Anyone who quotes me in their signature is an idiot -- Rusty Russell
