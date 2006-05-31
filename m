From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 2/2] iWARP Core Changes.
Date: Wed, 31 May 2006 15:30:35 -0500
Message-ID: <1149107435.7469.7.camel@stevo-desktop>
References: <20060531182650.3308.81538.stgit@stevo-desktop>
	 <20060531182654.3308.41372.stgit@stevo-desktop> <adaodxeypfd.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mshefty@ichips.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:61970 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S964782AbWEaUah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 16:30:37 -0400
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adaodxeypfd.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-05-31 at 12:17 -0700, Roland Dreier wrote:
>  > +EXPORT_SYMBOL(copy_addr);
> 
> I think if you want to export this, it needs a less generic name
> (something with an rdma_ prefix probably).  Otherwise it's going to
> collide someday...

ok.


The function is needed by the iwcm module, so that's why we exported it.
I could change the name to rdma_copy_addr(), or make the function a
static inline in a header file since its kinda small anyway...

Any preference?


