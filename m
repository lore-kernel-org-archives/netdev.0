From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH RFC] tun: add ioctl to modify vnet header size
Date: Wed, 17 Mar 2010 14:10:11 -0700
Message-ID: <OF526018DA.E6922CE9-ON882576E9.0073CB01-882576E9.007449E0@us.ibm.com>
References: <20100317154501.GA5244@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David S. Miller" <davem@davemloft.net>,
	David Woodhouse <David.Woodhouse@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Paul Moore <paul.moore@hp.com>, sri@linux.vnet.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100317154501.GA5244@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shouldn't we enforce a maximum too? Esp. if overflow/underflow
will break any of the checks when it's used.

                                +-DLS
