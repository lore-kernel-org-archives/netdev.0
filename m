From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch 1/2] vhost: potential integer overflows
Date: Tue, 12 Oct 2010 16:51:20 +0200
Message-ID: <20101012145120.GC6742@bicker>
References: <20101011172256.GF5851@bicker> <20101012122548.GA25446@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Juan Quintela <quintela@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101012122548.GA25446@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 12, 2010 at 02:25:48PM +0200, Michael S. Tsirkin wrote:
> 
> As far as I can see, maximum value for num is 64K - 1:
> 
>                 if (!s.num || s.num > 0xffff || (s.num & (s.num - 1))) {
>                         r = -EINVAL;
>                         break;
>                 }
> 
> How can any of the above two trigger?
> It seems easier to check value for sanity at a single place where it's
> passed from userspace to kernel.
> 

Gar.  Sorry for that.  My mistake.

regards,
dan carpenter

