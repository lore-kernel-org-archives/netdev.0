From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix AF_PACKET ABI breakage in 4.2
Date: Wed, 23 Sep 2015 11:09:26 -0700 (PDT)
Message-ID: <20150923.110926.1369752430685358746.davem@davemloft.net>
References: <1443019470.74600.6.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gkurz@linux.vnet.ibm.com,
	rusty@rustcorp.com.au, mst@redhat.com, linux-api@vger.kernel.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: dwmw2@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443019470.74600.6.camel@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 23 Sep 2015 15:44:30 +0100

> +#define VIO_LE virtio_legacy_is_little_endian()

When you define a shorthand macro, the defines to a function call,
make the macro have parenthesis too.
