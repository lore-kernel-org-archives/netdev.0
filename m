From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] NET: Normalize jiffies reported to userspace, in
 neighbor management code
Date: Tue, 11 Nov 2003 16:02:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111160200.72cee93a.davem@redhat.com>
References: <20031110.104536.79654717.yoshfuji@linux-ipv6.org>
	<20031110230233.254061da.davem@redhat.com>
	<20031111.163128.48152698.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20031111.163128.48152698.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 11 Nov 2003 16:31:28 -0600 (CST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> In article <20031110230233.254061da.davem@redhat.com> (at Mon, 10 Nov 2003 23:02:33 -0800), "David S. Miller" <davem@redhat.com> says:
> 
> > Another idea is to change do_proc_dointvec() to take a conversion function
> > pointer instead of this "conv" thing.  Maybe even proc_dointvec_minmax()
> > could be implemented in terms of do_proc_dointvec() with such a scheme.
> 
> This is essentially identical to what I thought.
> Okay, how about this?

This looks very nice, thank you Yoshfuji.

I'm asking Linus what we should do here.  It's a big change to
make to fix this bug, and if he thinks so too we'll just use
your original patch which is a safer version of the fix for 2.6.0
purposes.  If that happens, we'll integrate this nicer version
for 2.6.1 or something like this.

Thank you again.
