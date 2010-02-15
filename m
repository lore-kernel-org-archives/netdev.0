From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] tun: socket filter support
Date: Mon, 15 Feb 2010 16:46:19 +0100
Message-ID: <4B796C4B.50700@trash.net>
References: <cover.1266144917.git.mst@redhat.com> <20100214110110.GC30182@redhat.com> <4B79673B.7050908@trash.net> <201002151645.01410.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Moore <paul.moore@hp.com>,
	David Woodhouse <David.Woodhouse@intel.com>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201002151645.01410.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> On Monday 15 February 2010, Patrick McHardy wrote:
>> I'm not sure how the tun socket is exposed, but won't the regular
>> SO_ATTACH_FILTER/SO_DETACH_FILTER setsockopts already work for
>> tun sockets?
> 
> The tun socket is not exposed at all, it's an implementation detail
> of the tun/tap driver, which only has a chardev interface with
> ioctl methods.

I see, thanks for the explanation.
