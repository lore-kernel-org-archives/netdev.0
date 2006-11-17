From: Bryan O'Sullivan <bos@pathscale.com>
Subject: Re: [openib-general] [PATCH 02/13] Device Discovery and ULLD Linkage
Date: Fri, 17 Nov 2006 09:53:16 -0800
Message-ID: <455DF70C.7090400@pathscale.com>
References: <20061116035826.22635.61230.stgit@dell3.ogc.int> <20061116035837.22635.13571.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.pathscale.com ([64.160.42.68]:9688 "EHLO mx.pathscale.com")
	by vger.kernel.org with ESMTP id S933753AbWKQRw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 12:52:58 -0500
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <20061116035837.22635.13571.stgit@dell3.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:

> +static inline void *vzmalloc(int size)
> +{
> +	void *p = vmalloc(size);
> +	memset(p, 0, size);
> +	return p;
> +}

This isn't checking the return value from vmalloc.

Also, we could do with a generic vzalloc and vcalloc, just as we now 
have kzalloc and kcalloc.  There are lots of routines like this sitting 
around.

	<b
