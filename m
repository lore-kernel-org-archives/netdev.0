From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [NET] use fl6_{src,dst} etc.
Date: Tue, 15 Apr 2003 02:52:06 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030415.025206.31321166.yoshfuji@linux-ipv6.org>
References: <20030415.023158.36869337.yoshfuji@linux-ipv6.org>
	<20030414.103143.64788453.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030414.103143.64788453.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030414.103143.64788453.davem@redhat.com> (at Mon, 14 Apr 2003 10:31:43 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:

> How about the following instead?
> 
> +#define fl_ports_sport	uli_u.ports.sport
> +#define fl_ports_dport	uli_u.ports.dport
> +#define fl_icmp_type		uli_u.icmpt.type
> +#define fl_icmp_code		uli_u.icmpt.code
> 
> Ok?

fl_ip_{sport,dport}?
(fl_port_{sport,dport} sounds like "white horse is white" to me.)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
