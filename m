From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [NET] use fl6_{src,dst} etc.
Date: Mon, 14 Apr 2003 10:31:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030414.103143.64788453.davem@redhat.com>
References: <20030415.023158.36869337.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030415.023158.36869337.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Tue, 15 Apr 2003 02:31:58 +0900 (JST)

I think this idea needs a slight modification:

   +#define fl_sport	uli_u.ports.sport
   +#define fl_dport	uli_u.ports.dport
   +#define fl_type		uli_u.icmpt.type
   +#define fl_code		uli_u.icmpt.code

Other protocols like DecNET will use these areas, and I already know
that DecNET defines it's own struct member of the flow uli_u union
that itself has members named sport and dport.

How about the following instead?

+#define fl_ports_sport	uli_u.ports.sport
+#define fl_ports_dport	uli_u.ports.dport
+#define fl_icmp_type		uli_u.icmpt.type
+#define fl_icmp_code		uli_u.icmpt.code

Ok?
