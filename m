From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NETDEBUG network triggerable messages in IPv6
Date: Fri, 9 Apr 2004 18:21:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409182125.348fd6cd.ak@suse.de>
References: <20040409174847.2f0b7e77.ak@suse.de>
	<20040410.010051.129465789.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040410.010051.129465789.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 10 Apr 2004 01:00:51 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> In article <20040409174847.2f0b7e77.ak@suse.de> (at Fri, 9 Apr 2004 17:48:47 +0200), Andi Kleen <ak@suse.de> says:
> 
> > This wraps all potentially network triggerable printks in IPv6 with NETDEBUG.
> 
> I really do NOT like this. Please, please do not do this.

If you don't like it just keep NETDEBUG on. But for production systems being able 
to fill up logs from the network is not acceptable IMHO. Anyways default behaviour
does not change right now, it just allows to easily disable all this cruft for
people who want that.

-Andi
