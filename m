From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix numbering of lines in /proc/net/tcp
 (linux-2.6.0-test7)
Date: Tue, 14 Oct 2003 10:45:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031014104503.12ca907e.davem@redhat.com>
References: <200310141619.h9EGJWWB013461@ginger.lcs.mit.edu>
	<20031015.013848.133364889.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shep@alum.mit.edu, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
        jmorris@redhat.com, netdev@oss.sgi.com, torvalds@osdl.org,
        linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20031015.013848.133364889.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Oct 2003 01:38:48 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> In article <200310141619.h9EGJWWB013461@ginger.lcs.mit.edu> (at Tue, 14 Oct 2003 12:19:32 -0400), Tim Shepard <shep@alum.mit.edu> says:
> 
> > I am not sure what the behavior is supposed to be.  Is there a spec
> > anywhere for the interface with /proc/net/tcp?
> 
> Yes, I think the original is okay because the bucket is shared between
> tcp6 and tcp4, and I don't want to change this behavior in 2.6 from 2.4.x.
> (so, we need to fix 2.6.x.)

In the meantime I've applied Tim's patch because it is definitely
a step in the right direction and the current 2.6.x behavior makes
no sense at all :-)

We can add a fix on top to make 2.6.x behave more closely to 2.4.x
(by sharing numbers between v4 and v6).  If that proves to be very
difficult to do, it's not absolutely critical to preserve this behavior
I think.
