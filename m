From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: tcp socket missing from /proc/net/tcp
Date: Sun, 24 Aug 2003 10:07:53 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030824.100753.63798138.yoshfuji@linux-ipv6.org>
References: <m3lltk17er.fsf@lugabout.jhcloos.org>
	<20030823172710.478f30f9.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cloos@jhcloos.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030823172710.478f30f9.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030823172710.478f30f9.davem@redhat.com> (at Sat, 23 Aug 2003 17:27:10 -0700), "David S. Miller" <davem@redhat.com> says:

> On 23 Aug 2003 15:49:16 -0400
> "James H. Cloos Jr." <cloos@jhcloos.com> wrote:
> 
> > I've currently got an open ssh session to a remote box that does not
> > show up in /proc/net/tcp (I also checked /proc/net/tcp6 even though
> > the remote box doesn't do v6; it is not there either).
> 
> Not surprising, nothing seems to be initializing
> net/ipv6/tcp_ipv6.c:tcp6_seq_fops

net/ipv4/tcp_ipv4.c:tcp_proc_register() called by tcp6_proc_init() does this.
Or, do I miss something?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
