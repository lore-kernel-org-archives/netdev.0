From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Wed, 18 Apr 2012 19:31:40 -0400 (EDT)
Message-ID: <20120418.193140.1696968910620309822.davem@davemloft.net>
References: <CADZpyix6DZ93f8MQf3Aa1NVV7HCFMAXVAdzRMFBY7xWHHQMPog@mail.gmail.com>
	<20120418.001650.1042781402985153056.davem@davemloft.net>
	<CAKgNAkh46EMDWpessyi0n-EyNoRid-iW1O1RfUpTtzKDv0mZFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org, w@1wt.eu,
	alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKgNAkh46EMDWpessyi0n-EyNoRid-iW1O1RfUpTtzKDv0mZFw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 19 Apr 2012 10:50:40 +1200

> However, this is about longer-term improvement of the quality of
> implementation; in X years (choose your X) time, a lot of new
> application may not need to care about the old broken behavior.

There is really no value to this, the AF_UNIX NULL termination issue
is significantly different from the signal examples you mention.

If we're going to, like Carlos will, make mention in POSIX documents
that one must account for possible lack of NULL termination, there
is absolutely ZERO value in changing things because we are telling
application writers the state of reality which is that they have
to allot for this.

Please drop this issue, the discussion was over a long time ago, thank
you very much.
