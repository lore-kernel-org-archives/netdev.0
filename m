From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] tun: add ioctl to modify vnet header size
Date: Sun, 21 Mar 2010 20:17:32 -0700 (PDT)
Message-ID: <20100321.201732.186318609.davem@davemloft.net>
References: <20100317213504.GA7433@redhat.com>
	<OFB24B6EEE.B788B01F-ON882576E9.00789167-882576E9.0079198A@us.ibm.com>
	<20100317221117.GA7541@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, David.Woodhouse@intel.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	paul.moore@hp.com, sri@linux.vnet.ibm.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100317221117.GA7541@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 18 Mar 2010 00:11:17 +0200

> All this does is set how much of the buffer to skip, this option does
> not allocate any memory.  So if you set it to a value > length that you
> passed in, you get -EINVAL. Anything else should work.  Negative values
> are checked for and return -EINVAL when you try to set it.  At least,
> all that's by design - pls take a look at the code and if you see any
> issues, speak up please.
> 
> I agree we don't really need to support very large values here,
> it just seemed less work.

This all looks fine to me, submit a final version to me via
whatever means you feel is appropriate.
