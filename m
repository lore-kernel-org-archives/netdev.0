From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: clean-up ndisc printk's
Date: Wed, 11 Feb 2004 11:18:23 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211111823.2aa480b5.davem@redhat.com>
References: <20040210.164650.109511390.yoshfuji@linux-ipv6.org>
	<20040211111616.34c18a2c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040211111616.34c18a2c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Feb 2004 11:16:16 -0800
"David S. Miller" <davem@redhat.com> wrote:

> On Tue, 10 Feb 2004 16:46:50 +0900 (JST)
> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:
> 
> > D: print KERN_xxx appropriately.
> > D: put net_ratelimit() inside the macro.
> > D: re-arrange levels.

Actually, no, this makes GCC upset.  I have to revert the patch.

Please fix this:

net/ipv6/ndisc.c:1283:40: pasting "(" and "KERN_ERR" does not give a valid preprocessing token
net/ipv6/ndisc.c:1442:31: pasting "(" and "KERN_ERR" does not give a valid preprocessing token

Thanks.
