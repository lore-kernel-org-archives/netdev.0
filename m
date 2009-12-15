From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH] Subject: virtio: Add unused buffers detach from
 vring
Date: Tue, 15 Dec 2009 11:14:07 -0800
Message-ID: <1260904447.4387.85.camel@localhost.localdomain>
References: <200911231123.18898.rusty@rustcorp.com.au>
	 <20091208122134.GA17286@redhat.com>
	 <1260534506.30371.6.camel@localhost.localdomain>
	 <1260535613.30371.24.camel@localhost.localdomain>
	 <20091213114320.GC7074@redhat.com>
	 <1260828518.8716.105.camel@localhost.localdomain>
	 <20091215113327.GC13110@redhat.com>
	 <1260894320.4387.64.camel@localhost.localdomain>
	 <20091215163901.GA24015@redhat.com>
	 <1260902573.4387.76.camel@localhost.localdomain>
	 <20091215184740.GD25724@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933410AbZLOTOY@vger.kernel.org>
In-Reply-To: <20091215184740.GD25724@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Michael,

On Tue, 2009-12-15 at 20:47 +0200, Michael S. Tsirkin wrote:
> > +                     detach_buf(vq, i);
> > +                     END_USE(vq);
> > +                     return vq->data[i];
> 
> In fact, this will return NULL always, won't it?

Nope, I changed the destroy to detach and return the buffers without
destroying them within the call. I thought it might be useful in some
other case. 

Maybe I should put destroy call back?

Thanks
Shirley
