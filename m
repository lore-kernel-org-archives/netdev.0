From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH][VHOST] fix race with guest on multi-buffer used buffer
	updates
Date: Mon, 24 May 2010 20:52:03 +0300
Message-ID: <20100524175203.GB6749@redhat.com>
References: <20100524164205.GA6664@redhat.com> <OF4F730E37.19043E17-ON8825772D.00616972-8825772D.0062068B@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OF4F730E37.19043E17-ON8825772D.00616972-8825772D.0062068B@us.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 24, 2010 at 10:50:44AM -0700, David Stevens wrote:
> Michael S. Tsirkin <mst@redhat.com> wrote on 05/24/2010 09:42:05 AM:
> > 
> > I see. The logging is still bugg though I think.
> 
> Possibly; migration isn't working for me under load even
> without mergeable buffers (investigating), so I haven't
> yet been able to test wrap w/ logging, but did you see
> something specific that's wrong?
> 
>                                                 +-DLS

Yes, code only logs a single entry as dirty even if
multiple entries have been written.

-- 
MST
