From: James Morris <jmorris@redhat.com>
Subject: Re: Bug somewhere in crypto or ipsec stuff
Date: Wed, 29 Oct 2003 22:22:50 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0310292221320.23405-100000@thoron.boston.redhat.com>
References: <20031030.121732.12858700.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: paulus@samba.org, <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>,
        <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20031030.121732.12858700.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Oct 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:


> I would just disallow name == NULL,
> well, what algorithm do you expect?

Good question.  It seems to me to be a bug in the calling code if it is 
trying to look up nothing -- I'd rather not paper that over.


- James
-- 
James Morris
<jmorris@redhat.com>
