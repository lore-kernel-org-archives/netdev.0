From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Thu, 19 Apr 2012 11:19:09 +0100
Message-ID: <20120419111909.616bef70@pyramind.ukuu.org.uk>
References: <4F8D497F.8060601@gmail.com>
	<20120417.223614.629911246108750471.davem@davemloft.net>
	<CADZpyix6DZ93f8MQf3Aa1NVV7HCFMAXVAdzRMFBY7xWHHQMPog@mail.gmail.com>
	<20120418.001650.1042781402985153056.davem@davemloft.net>
	<CAKgNAkh46EMDWpessyi0n-EyNoRid-iW1O1RfUpTtzKDv0mZFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org,
	jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org, w@1wt.eu
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKgNAkh46EMDWpessyi0n-EyNoRid-iW1O1RfUpTtzKDv0mZFw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> 3. Considering these two sets:
> 
>   (a) [applications that rely on the assumption that there
>        is a null terminator inside sizeof(sun_path) bytes]
>   (b) [applications that would break if the kernel behavior changed]
> 
>   I suspect that set (a) is rather larger than set (b)--or, more
>   likely still, applications ensure they go for the lowest common
>   denominator limit of 92 (HP-UX) or 104 (historical BSD limit)
>   bytes, and so avoid this issue completely.

Or another way of putting it

3(a)	Sloppy coding that may have lots of other bugs

3(b)	Interfaces and code we promised not to break.



Alan
