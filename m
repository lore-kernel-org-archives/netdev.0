From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] dst->{in,out}put() clean-up
Date: Wed, 19 Feb 2003 13:36:59 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030219.133659.71995717.davem@redhat.com>
References: <20030220.022840.48274187.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030220.022840.48274187.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Thu, 20 Feb 2003 02:28:40 +0900 (JST)

   This patch removes dst->input() and dst->output(), and use
   dst_input() and dst_output() instead.
   
   Patch is against linux-2.5.62.
   
   Thank you in advance.
   
Thank you, it is applied.

I have made one tiny improvement, in ipv4/igmp.c case we can
totally eliminate output_maybe_reroute() function and pass
directly dst_output() to NF_HOOK.  Once transformation from
dst->output() to dst_output() is applied, these old inline functions
for NF_HOOK no longer have purpose.

Thank you again.
