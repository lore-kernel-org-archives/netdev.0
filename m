From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Nov 8 (netdev, netfilter)
Date: Tue, 8 Nov 2016 10:22:34 -0800
Message-ID: <44b626cf-7cc5-a82d-299b-5ce7418f53db@infradead.org>
References: <20161108183855.5f8c209a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        netfilter-devel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161108183855.5f8c209a@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/07/16 23:38, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20161028:


on i386 or x86_64:

net/built-in.o: In function `nf_sk_lookup_slow_v4':
(.text+0x97414): undefined reference to `udp4_lib_lookup'

when these are not enabled:
#if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_SOCKET) || \
    IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY)

and
CONFIG_NF_SOCKET_IPV4=y

See net/ipv4/netfilter/nf_socket_ipv4.c.


Reported-by: Randy Dunlap <rdunlap@infradead.org>
-- 
~Randy
