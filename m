From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] decnet: fix shutdown parameter checking
Date: Fri, 31 Aug 2012 15:57:19 -0400 (EDT)
Message-ID: <20120831.155719.2228399422573401952.davem@davemloft.net>
References: <1346035027-2347-1-git-send-email-xi.wang@gmail.com>
	<1346059001.2703.7.camel@menhir>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xi.wang@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: swhiteho@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346059001.2703.7.camel@menhir>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Whitehouse <swhiteho@redhat.com>
Date: Mon, 27 Aug 2012 10:16:41 +0100

> On Sun, 2012-08-26 at 22:37 -0400, Xi Wang wrote:
>> The allowed value of "how" is SHUT_RD/SHUT_WR/SHUT_RDWR (0/1/2),
>> rather than SHUTDOWN_MASK (3).
>> 
>> Signed-off-by: Xi Wang <xi.wang@gmail.com>
> Acked-by: Steven Whitehouse <swhiteho@redhat.com>

Applied to net-next.

> Although it could be argued that we should also continue to accept the
> value 3 just in case there is any userland software out there which
> sends that value,

True, but this is a rather standard BSD socket interface with a very
specific small set of legitimate input parameters.  Allowing
deviation, even for compatability for specific protocols, is largely
unwise.
