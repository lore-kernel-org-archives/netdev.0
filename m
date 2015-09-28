From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Subject: Re: simplify configfs attributes
Date: Mon, 28 Sep 2015 14:12:43 +0200
Message-ID: <56092EBB.3040603@samsung.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Felipe Balbi <balbi@ti.com>, Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>, Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <target-devel-owner@vger.kernel.org>
In-reply-to: <1443189000-13398-1-git-send-email-hch@lst.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Christoph,

W dniu 25.09.2015 o 15:49, Christoph Hellwig pisze:
> This series consolidates the code to implement configfs attributes
> by providing the ->show and ->store method in common code and using
> container_of in the methods to access the containing structure.
>
> This reduces source and binary size of configfs consumers a lot.
>

Thank you for this series. It is definitely the way to go.
I reviewed it as far as the configfs consumers which I wrote
or have experience with are concerned. There are some minor
issues which you perhaps can call nitpicks. In the last patch
(23/23) I think you meant something different when changing
the documentation - please see my response to that patch.

But otherwise this series is very welcome.

AP
