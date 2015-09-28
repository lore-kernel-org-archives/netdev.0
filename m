From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 03/23] usb-gadget/uvc: use per-attribute show and store
	methods
Date: Mon, 28 Sep 2015 15:39:43 +0200
Message-ID: <20150928133943.GC30453@lst.de>
References: <1443189000-13398-1-git-send-email-hch@lst.de> <1443189000-13398-4-git-send-email-hch@lst.de> <5609260A.7010806@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Felipe Balbi <balbi@ti.com>, Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5609260A.7010806@samsung.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 28, 2015 at 01:35:38PM +0200, Andrzej Pietrasiewicz wrote:
>> -#define UVCG_STREAMING_CONTROL_SIZE	1
>
> Moving this define seems an unrelated change to me.

I can move it back - this one wasn't intentional.

>> +#define identity_conv(x) (x)
>
> What is this needed for here?
>
> This #define is not used near the place it is defined.
> Throughout the file the identity_conv is being defined multiple times,
> each time near the place it is used and then undefined.
>
> Without this line the code still compiles.

Looks like a copy & paste erro.  I'll fix it up.
