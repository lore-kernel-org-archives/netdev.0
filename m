From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun: add ioctl to modify vnet header size
Date: Wed, 17 Mar 2010 23:35:04 +0200
Message-ID: <20100317213504.GA7433@redhat.com>
References: <20100317154501.GA5244@redhat.com> <OF526018DA.E6922CE9-ON882576E9.0073CB01-882576E9.007449E0@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	David Woodhouse <David.Woodhouse@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Paul Moore <paul.moore@hp.com>, sri@linux.vnet.ibm.com
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OF526018DA.E6922CE9-ON882576E9.0073CB01-882576E9.007449E0@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 17, 2010 at 02:10:11PM -0700, David Stevens wrote:
> Shouldn't we enforce a maximum too? Esp. if overflow/underflow
> will break any of the checks when it's used.
> 
>                                 +-DLS

So the maximum is MAX_INT :)
I don't think it can break any checks that aren't
already broken - what do you have in mind?


-- 
MST
