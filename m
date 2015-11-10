From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: netfilter: fix GCC uninitialized warning
Date: Tue, 10 Nov 2015 13:45:53 +0100
Message-ID: <20151110124553.GA22692@salvia>
References: <1446835694-6967-1-git-send-email-0x7f454c46@gmail.com>
 <20151106191008.GA2362@salvia>
 <CAJwJo6Ybv9pXSFJqxtPR=W0+6JDfh8M7DtFQYV6VnuWjjWpTNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dmitry Safonov <0x7f454c46@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJwJo6Ybv9pXSFJqxtPR=W0+6JDfh8M7DtFQYV6VnuWjjWpTNA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 06, 2015 at 10:13:16PM +0300, Dmitry Safonov wrote:
> I thought, it was decided to use 0/NULL/whatever, than uninitialized_var()?
> Is right now?
> http://thread.gmane.org/gmane.linux.kernel/1383415

I overlook that one. We should stick to mainstream policies as much as
possible.

Arnd just sent a patch to address one of this by initializing the
variable: http://patchwork.ozlabs.org/patch/542259/

Please follow up with a patch to initialize the variable to avoid the
warning in other spots.

Thanks.
