From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 5/5] net: Block MSG_CMSG_COMPAT in send(m)msg and
 recv(m)msg
Date: Thu, 6 Jun 2013 13:01:05 +1000
Message-ID: <20130606130105.6e51066f@kryten>
References: <cover.1369177867.git.luto@amacapital.net>
	<aa015609319786835bcab445d507faa75c11f111.1369177867.git.luto@amacapital.net>
	<CAEjGV6xcF776C6N6VxeMY0Vyk+X51oNixdbN42-xkWjQOaMEQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
	linux-kernel@vger.kernel.org, x86@kernel.org,
	trinity@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Linux PPC dev <linuxppc-dev@ozlabs.org>,
	torvalds@linux-foundation.org
To: Michael Neuling <mikey@neuling.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEjGV6xcF776C6N6VxeMY0Vyk+X51oNixdbN42-xkWjQOaMEQA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> This is causing a regression on 64bit powerpc with 32bit usermode.
> When I hit userspace, udev is broken and I suspect all networking is
> broken as well.
> 
> Can we please revert 1be374a0518a288147c6a7398792583200a67261
> upstream?
> 
> Found via bisect.

Doesn't this patch break compat_sys_sendmsg and compat_sys_recvmsg?
We'd need to move the guts of sys_* into compat_sys_* to fix it.

Anton
