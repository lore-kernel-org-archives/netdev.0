From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: Bug somewhere in crypto or ipsec stuff
Date: Thu, 30 Oct 2003 12:41:24 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031030.124124.26191552.yoshfuji@linux-ipv6.org>
References: <20031030.121732.12858700.yoshfuji@linux-ipv6.org>
	<Xine.LNX.4.44.0310292221320.23405-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        davem@redhat.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@redhat.com
In-Reply-To: <Xine.LNX.4.44.0310292221320.23405-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Xine.LNX.4.44.0310292221320.23405-100000@thoron.boston.redhat.com> (at Wed, 29 Oct 2003 22:22:50 -0500 (EST)), James Morris <jmorris@redhat.com> says:

> On Thu, 30 Oct 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> 
> 
> > I would just disallow name == NULL,
> > well, what algorithm do you expect?
> 
> Good question.  It seems to me to be a bug in the calling code if it is 
> trying to look up nothing -- I'd rather not paper that over.

Do you mean that we need to fix the caller?

Well, people may want to get just any algorithm.
In such case,
 - crypto allows name == NULL, and return any algorithm
   (for example, an algorithm that we see first.)
 - caller may filter name == NULL case if it is ambiguous in their context.

--yoshfuji
