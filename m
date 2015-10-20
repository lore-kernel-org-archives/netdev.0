From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 1/2] crypto/x509: Fix unaligned access in x509_get_sig_params()
Date: Tue, 20 Oct 2015 10:50:38 +0100
Message-ID: <21610.1445334638@warthog.procyon.org.uk>
References: <288f39ff7c8b0bc60693e338fc8f6cea9008d443.1445286755.git.sowmini.varadhan@oracle.com> <cover.1445286755.git.sowmini.varadhan@oracle.com> <cover.1445286755.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, davem@davemloft.net,
	zohar@linux.vnet.ibm.com, David.Woodhouse@intel.com,
	steffen.klassert@secunet.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <288f39ff7c8b0bc60693e338fc8f6cea9008d443.1445286755.git.sowmini.varadhan@oracle.com>
Content-ID: <21609.1445334638.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sowmini Varadhan <sowmini.varadhan@oracle.com> wrote:

> x509_get_sig_params() has the same code pattern as the one in
> pkcs7_verify() that is fixed by commit 62f57d05e287 ("crypto: pkcs7 - Fix
> unaligned access in pkcs7_verify()") so apply a similar fix here: make
> sure that desc is pointing at an algined value past the digest_size,
> and take alignment values into consideration when doing kzalloc()
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Acked-by: David Howells <dhowells@redhat.com>
