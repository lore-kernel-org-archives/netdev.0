From: James Morris <jmorris@intercode.com.au>
Subject: Re: fix TCP roundtrip time update code
Date: Wed, 4 Jun 2003 10:24:14 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306041021450.28035-100000@excalibur.intercode.com.au>
References: <16092.60612.352739.581639@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Martin Josefsson <gandalf@wlug.westbo.se>, <kuznet@ms2.inr.ac.ru>,
   <linux-kernel@vger.kernel.org>, <linux-ia64@linuxia64.org>,
   <netdev@oss.sgi.com>, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: davidm@hpl.hp.com
In-Reply-To: <16092.60612.352739.581639@napali.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Jun 2003, David Mosberger wrote:

>   Martin> I tested this patch and it looks like it has cured my
>   Martin> mysterious TCP stalls.
> 
> Yes, this sounds reasonable.  I wasn't very clear on this point, but
> "by going south" I meant that TCP is starting to misbehave.  In
> particular, you'll likely end up with the kernel aborting ESTABLISHED
> TCP connections with extreme prejudice (and in violation of the TCP
> protocol), because it thought that it had been unable to communicate
> with the remote end for a _very_ long time.  The net effect typically
> is that you end up with one end having a connection that's in the
> ESTABLISHED state and the other end having no trace of that
> connection.

David,

This might be the solution to one of the 'must-fix' bugs for the
networking, which nobody so far was quite able to track down.


- James
-- 
James Morris
<jmorris@intercode.com.au>
