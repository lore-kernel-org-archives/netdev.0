From: Martin Pool <mbp@samba.org>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Mon, 30 Sep 2002 19:59:10 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020930095909.GA8063@toey.sourcefrog.net>
References: <20020926054721.GA6039@samba.org> <200209261309.RAA17837@sex.inr.ac.ru> <20020926.134608.31605412.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, ak@muc.de, netdev@oss.sgi.com, Alan.Cox@linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20020926.134608.31605412.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 26 Sep 2002, "David S. Miller" <davem@redhat.com> wrote:
>    From: kuznet@ms2.inr.ac.ru
>    Date: Thu, 26 Sep 2002 17:09:11 +0400 (MSD)
> 
>    I do not understand why tcp_push_pending_frames() was not used
>    there... maybe, there was some reason not to use it.
>    
>    Dave, do you not remember this?

So where does this leave us?  

Was the patch we came up with correct?  It looks reasonable to me, but
I don't know the stack well enough to be sure.  I think it would be
nice if it could be fixed in 2.2.

Let me know if there's anything I can do by way of testing, etc.

-- 
Martin 
