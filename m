From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSec Oops when deleting an ip address
Date: Fri, 21 May 2004 14:43:46 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040521144346.7887dbf0.davem@redhat.com>
References: <20040510134958.13691.qmail@mason.oriente.labs.it>
	<20040521131950.GA20040@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bergonz@nospam.org, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040521131950.GA20040@gondor.apana.org.au>
List-Id: netdev.vger.kernel.org

On Fri, 21 May 2004 23:19:50 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> doing a mod_timer on a live state without holding a lock or for that
> matter not even checking whether the state is dead is definitely a bad
> idea

Applied, thanks Herbert.
