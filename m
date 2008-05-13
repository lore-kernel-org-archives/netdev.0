From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: New GIT net tree naming...
Date: Tue, 13 May 2008 09:26:30 -0400
Message-ID: <20080513132630.GC3279@tuxdriver.com>
References: <20080419.173510.257216556.davem@davemloft.net> <20080508014358.GE3412@tuxdriver.com> <200805080906.29603.hs4233@mail.mn-solutions.de> <20080508144046.GA3515@tuxdriver.com> <1ba2fa240805121039u1fc4273eh706c8868748b500c@mail.gmail.com> <20080512184715.GA18910@tuxdriver.com> <1ba2fa240805130305q207067b0n572b95340a3745d6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Holger Schurig <hs4233-x6+DxXLjN1AJvtFkdXX2Hg4jNU5vUVPG@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1ba2fa240805130305q207067b0n572b95340a3745d6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 13, 2008 at 01:05:22PM +0300, Tomas Winkler wrote:

> I'm not able to clone neither wireless-2.6.git nor net-2.6.git through http
> I'm behind a firewall so git protocol is not an option
> 
> 
> git-clone  ttp://www.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
> Initialized empty Git repository in ....
> Cannot get remote repository information.
> Perhaps git-update-server-info needs to be run there?
> 
> git-clone  http://www.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.gi
> Getting pack list for
> http://www.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git
> Getting index for pack 1c206683ae18d8f0b4833dcee50c8e1c76832df9
> Getting pack list for
> http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git/
> error: Unable to find 090b293b87792a815cf51aeccb590ec37c90cfa3 under
> http://www.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git
> Cannot obtain needed blob 090b293b87792a815cf51aeccb590ec37c90cfa3
> while processing commit 6e40a915de82e00d18f75941e531b40c4e0d94c4.
> Waiting for http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git//objects/9a/eb872460a5dcab8b4baf13125d0177f865f393
> got 334974abd063c20dc64dd32724425be36b90cebc
> got 9aeb872460a5dcab8b4baf13125d0177f865f393
> Waiting for http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git//objects/ab/ef366d1ab8fe2ac484039976600938f6c76db3
> Received DONE message for unknown request!

I got a similar message when trying to clone using http://.  I was
able to clone using git:// without a problem.

FWIW I have the post-update hook enabled, and I didn't change my
normal practices for publishing trees on kernel.org.  I'm not sure
what is happening.  Anyone have an idea as to what is happening?

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
