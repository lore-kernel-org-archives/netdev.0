From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: tunnels - enable module autoloading
Date: Thu, 15 May 2014 14:32:02 -0700
Message-ID: <20140515143202.53ca8033@nehalam.linuxnetplumber.net>
References: <1399970908-9973-1-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	kuznet@ms2.inr.ac.ru, davem@davemloft.net
To: Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399970908-9973-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 May 2014 10:48:28 +0200
Tom Gundersen <teg@jklm.no> wrote:

> Enable the module alias hookup to allow tunnel modules to be autoloaded on demand.
> 
> This is in line with how most other netdev kinds work, and will allow userspace
> to create tunnels without having CAP_SYS_MODULE.
> 
> Signed-off-by: Tom Gundersen <teg@jklm.no>
> Tested-by: Susant Sahani <susant@redhat.com>
> ---
>  net/ipv4/ipip.c       | 1 +
>  net/ipv6/ip6_tunnel.c | 1 +
>  net/ipv6/sit.c        | 1 +
>  3 files changed, 3 insertions(+)

But tunnel modules are autoloaded now.
If I create a tunnel with ip tunnel based on the existing MODULE_ALIAS_NETDEV().
