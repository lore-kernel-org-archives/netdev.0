From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Add MSG_WAITFORONE flag to recvmmsg
Date: Fri, 26 Mar 2010 20:54:28 -0700 (PDT)
Message-ID: <20100326.205428.44779758.davem@davemloft.net>
References: <84621a61003261555q2c78f6a8o5b438113bed6bd2@mail.gmail.com>
	<a36005b51003261907x7ebe057bt2d541f63f20f632b@mail.gmail.com>
	<20100327021803.GA10866@xpc.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@redhat.com, drepper@gmail.com,
	linux-kernel@vger.kernel.org
To: blblack@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100327021803.GA10866@xpc.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brandon L Black <blblack@gmail.com>
Date: Fri, 26 Mar 2010 21:18:03 -0500

> 
> From: Brandon L Black <blblack@gmail.com>
> 
> Add new flag MSG_WAITFORONE for the recvmmsg() syscall.
> When this flag is specified for a blocking socket, recvmmsg()
> will only block until at least 1 packet is available.  The
> default behavior is to block until all vlen packets are
> available.  This flag has no effect on non-blocking sockets
> or when used in combination with MSG_DONTWAIT.
> 
> Signed-off-by: Brandon L Black <blblack@gmail.com>

Arnaldo, please review this, thanks.
