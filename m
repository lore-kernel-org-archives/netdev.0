From: "Christopher Friesen" <cfriesen@nortel.com>
Subject: Re: netlink nlmsg_pid supposed to be pid or tid?
Date: Mon, 21 Nov 2005 16:51:03 -0600
Message-ID: <43824F57.1040007@nortel.com>
References: <E1EeJwF-0006wc-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751232AbVKUWv1@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1EeJwF-0006wc-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

> As I said before, you should not rely on getpid() to work.

> You should always use getsockaddr(2) to get your local address.

Should that be getsockname(2)?  Anyways, I now understand the issues.

As it turns out, we were actually already calling getsockname() a bit 
earlier in the code path, so we can just use the "pid" value from there.

Chris
