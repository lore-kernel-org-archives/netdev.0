From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] SNMP_ADD_STATS
Date: Thu, 13 Jun 2002 02:11:19 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020613021119.A11732@wotan.suse.de>
References: <20020612182348.GP1073@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S.Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Content-Disposition: inline
In-Reply-To: <20020612182348.GP1073@conectiva.com.br>
List-Id: netdev.vger.kernel.org

> #define IP_ADD_STATS(field,incr) SNMP_ADD_STATS(ip_statistics, field, incr)
> 
> Any objections?

Better use per_cpu data in 2.5 (<asm/percpu.h>) for the MIBs.

That's much more efficient on some architectures, uses less memory on all
and is also cleaner.

-Andi
