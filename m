From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH V2 0/5] macvtap TX zero copy between guest and host
 kernel
Date: Mon, 14 Feb 2011 15:06:19 -0800
Message-ID: <1297724779.14710.3.camel@localhost.localdomain>
References: <1291974691.2167.24.camel@localhost.localdomain>
	 <20110214130957.GA3128@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110214130957.GA3128@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-02-14 at 15:09 +0200, Michael S. Tsirkin wrote:
> What's the status here?  Since there are core net changes, we'll need
> to
> see the final version soon if it's to appear in 2.6.39.

I am updating the patch and retesting it for the new kernel. I am trying
to understand why zero copy patch caused small message size guest exits
doubled.

> Could the problem be related to the patch
>         virtio_net: Add schedule check to napi_enable call
> ?

Not sure, I will retest w/i this patch.

> Also, I expect there should be driver patches for some
> devices? Where are they? 

Yes, a NET_F_ZEROCOPY... flag is introduced for the device we we want to
support zero copy.

Thanks
Shirley

