From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] virtio_net: lower limit on buffer size
Date: Fri, 2 Jun 2017 16:25:36 -0400
Message-ID: <20170602202536.GA24411@fieldses.org>
References: <1496361148-4603-1-git-send-email-mst@redhat.com>
 <3dd90d56-7110-bb9e-0b7f-4c8a8003a57f@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        linux-kernel@vger.kernel.org,
        Mikulas Patocka <mpatocka@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3dd90d56-7110-bb9e-0b7f-4c8a8003a57f@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2017 at 12:34:57PM +0300, Sergei Shtylyov wrote:
> Hello!
> 
> On 6/2/2017 2:56 AM, Michael S. Tsirkin wrote:
> 
> >commit d85b758f72b0 "virtio_net: fix support for small rings"
> 
>    Commit d85b758f72b0 ("virtio_net: fix support for small rings")
> 
> >was supposed to increase the buffer size for small rings
> >but had an unintentional side effect of decreasing
> >it for large rings. This seems to break some setups -
> >it's not yet clear why, but increasing buffer size
> >back to what it was before helps.
> >
> >Fixes: d85b758f72b0 "virtio_net: fix support for small rings"
> 
> Fixes: d85b758f72b0 ("virtio_net: fix support for small rings")

I may be bikeshedding, but, personally I never do the parens--they're
redundant given the quotes, and space is often tight.

--b.

> 
> >Reported-by: Mikulas Patocka <mpatocka@redhat.com>
> >Reported-by: "J. Bruce Fields" <bfields@fieldses.org>
> >Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> [...]
> 
> MBR, Sergei
