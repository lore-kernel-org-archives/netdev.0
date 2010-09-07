From: Miloslav Trmac <mitr@redhat.com>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 7 Sep 2010 10:54:24 -0400 (EDT)
Message-ID: <28410754.1087391283871264222.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
References: <20100907145127.GA13027@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20100907145127.GA13027@infradead.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


----- "Christoph Hellwig" <hch@infradead.org> wrote:

> On Tue, Sep 07, 2010 at 10:34:25AM -0400, Miloslav Trmac wrote:
> > - Don't use a FD for associated data that is limited to 16? bytes
> > 
> > - Don't use file descriptors for input data at all, if it makes the
> interface so complex.
> 
> Calling into the kernel for 16 bytes of crypto is a braindead idea to
> start with.  To preve3nt idiots like you
1) It was Herbert who used AEAD as an example
2) That's how AEAD works: One large input stream, one very small.
     Mirek
