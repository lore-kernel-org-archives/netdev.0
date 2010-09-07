From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 7 Sep 2010 10:51:27 -0400
Message-ID: <20100907145127.GA13027@infradead.org>
References: <1847066281.1081601283869883727.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
 <421339997.1082251283870065826.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Miloslav Trmac <mitr@redhat.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <421339997.1082251283870065826.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 07, 2010 at 10:34:25AM -0400, Miloslav Trmac wrote:
> - Don't use a FD for associated data that is limited to 16? bytes
> 
> - Don't use file descriptors for input data at all, if it makes the interface so complex.

Calling into the kernel for 16 bytes of crypto is a braindead idea to
start with.  To preve3nt idiots like you from abusing it we should
simply limit any userlevel crypto API to:

 a) hardware crypto that is not directly user space accesible
 b) page size or larger data
