From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2 net-next 2/4] aio: prefer aio_op op over iter_op
Date: Thu, 19 Mar 2015 16:22:18 +0000
Message-ID: <20150319162218.GP29656@ZenIV.linux.org.uk>
References: <20150316161508.16418.23674.stgit@tstruk-mobl1>
 <20150316161519.16418.63051.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-aio@kvack.org,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	ying.xue@windriver.com, bcrl@kvack.org,
	linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150316161519.16418.63051.stgit@tstruk-mobl1>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 16, 2015 at 09:15:19AM -0700, Tadeusz Struk wrote:
> AIO interface should prefer AIO operations over iter_op

Again, NAK - the only reason you need that one is your insistence on
having separate sock_aio_{read,write}().  Doctor, it hurts when I do it...
