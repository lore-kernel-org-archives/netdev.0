From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] change format of LSM hooks
Date: Thu, 17 Oct 2002 05:33:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1821PX-0004Ob-00@starship>
References: <20021015194545.GC15864@kroah.com> <20021016000706.GI16966@kroah.com> <20021017114127.759e0e81.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: davem@redhat.com, becker@scyld.com, jmorris@intercode.com.au,
   kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-security-module@wirex.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>, Greg KH <greg@kroah.com>
In-Reply-To: <20021017114127.759e0e81.rusty@rustcorp.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 17 October 2002 03:41, Rusty Russell wrote:
> This also allows someone in the future to do:
> 
> 	#define security_call(func, default_ret, ...) \
> 		({ if (try_inc_mod_count(security_ops->owner))
> 			(security_ops->func(__VA_ARGS__));
> 		   else
> 			(default_ret);
> 		})

Hopefully, dec_mod_count as well.

-- 
Daniel
