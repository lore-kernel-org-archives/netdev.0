From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: MOD_{INC,SEC}_USE_COUNT() in net/ipv{4,6}
Date: Thu, 10 Apr 2003 16:11:51 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030410191151.GM6070@conectiva.com.br>
References: <20030409.180004.08009488.davem@redhat.com> <200304100254.GAA06560@sex.inr.ac.ru> <20030409.232918.112623123.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030409.232918.112623123.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm studying how to properly do this for net_proto_family, hope to get this
done in the weekend. I'm doing the try_module_get(net_families[family]->owner)
at sock_create, etc.

- Arnaldo

Em Wed, Apr 09, 2003 at 11:29:18PM -0700, David S. Miller escreveu:
>    From: kuznet@ms2.inr.ac.ru
>    Date: Thu, 10 Apr 2003 06:54:38 +0400 (MSD)
>    
>    Why not to delete this things instead? Calls of these functions
>    from inside of module is completely meaningless.
> 
> Better to implement correctly than to outright delete.
> 
