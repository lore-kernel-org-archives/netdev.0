From: Martin Pool <mbp@samba.org>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Wed, 18 Sep 2002 12:09:29 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020918020927.GB2285@samba.org>
References: <20020918020346.GA2285@samba.org> <20020917.185801.76605813.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@muc.de, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Alan.Cox@linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20020917.185801.76605813.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 17 Sep 2002, "David S. Miller" <davem@redhat.com> wrote:
> 
> Which 2.2.x kernel exactly?  

The person who originally reported the bug to me tried .16 and .18,
and I just reproduced it on .21, which was the most recent when I
started investigating.  

I can try .22 or a .pre if you think it's already fixed somewhere.

> You don't specify this.

(Actually it was in the corked_demo.c comment header.)

> If it's old, please try to reproduce with more recent 2.2.x
> kernels, and even more importantly make sure 2.4.x does not
> exhibit this behavior.

I can't reproduce it on 2.4.18 or .19.  It looked to me like
tcp_snd_test() and related stuff had been substantially rewritten.

-- 
Martin 
