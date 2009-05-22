From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/1] isdn: Use kernel_{send,recv}msg instead of open
	coding
Date: Thu, 21 May 2009 22:34:24 -0300
Message-ID: <20090522013424.GP5956@ghostprotocols.net>
References: <20090521154126.GH5956@ghostprotocols.net> <20090521.151443.79607416.davem@davemloft.net> <20090521.164929.241809587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: isdn@linux-pingi.de, paul.moore@hp.com, netdev@vger.kernel.org,
	vanhoof@redhat.com, williams@redhat.com,
	linux-security-module@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090521.164929.241809587.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Thu, May 21, 2009 at 04:49:29PM -0700, David Miller escreveu:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 21 May 2009 15:14:43 -0700 (PDT)
> 
> > From: Arnaldo Carvalho de Melo <acme@redhat.com>
> > Date: Thu, 21 May 2009 12:41:26 -0300
> > 
> >> Reducing the number of direct users of sock_{recv,send}msg.
> >> 
> >> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> > 
> > Nice work, applied, thanks!
> 
> Nevermind, I'm reverting, this doesn't even build:
> 
> drivers/isdn/mISDN/l1oip_core.c: In function 'l1oip_socket_send':
> drivers/isdn/mISDN/l1oip_core.c:354: warning: passing argument 3 of 'kernel_sendmsg' makes pointer from integer without a cast
> drivers/isdn/mISDN/l1oip_core.c:354: error: too few arguments to function 'kernel_sendmsg'
> drivers/isdn/mISDN/l1oip_core.c: In function 'l1oip_socket_thread':
> drivers/isdn/mISDN/l1oip_core.c:729: warning: passing argument 3 of 'kernel_recvmsg' makes pointer from integer without a cast
> drivers/isdn/mISDN/l1oip_core.c:729: error: too few arguments to function 'kernel_recvmsg'

I should have said "not even compile tested".

Will understand stricter questioning in the future.

Damn, these are not present in at least the distro kernel build I
tried...

- Arnaldo
