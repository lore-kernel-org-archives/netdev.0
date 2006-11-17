From: Bryan O'Sullivan <bos@pathscale.com>
Subject: Re: [openib-general] [PATCH  09/13] Core WQE/CQE Types
Date: Fri, 17 Nov 2006 10:45:07 -0800
Message-ID: <455E0333.70602@pathscale.com>
References: <20061116035826.22635.61230.stgit@dell3.ogc.int>	 <20061116035912.22635.21736.stgit@dell3.ogc.int>	 <455DFD23.8050504@pathscale.com> <1163788339.8457.95.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.pathscale.com ([64.160.42.68]:17116 "EHLO mx.pathscale.com")
	by vger.kernel.org with ESMTP id S1755795AbWKQSos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 13:44:48 -0500
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <1163788339.8457.95.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:

> It passes sparse with only a few warnings about calling memset() with a
> size > 100000.

You need to pass in CF=-D__CHECK_ENDIAN__ too, on the kernel build 
command line.  Otherwise, the endianness annotations aren't turned on in 
the kernel headers, and you get this nice false sense of security.

  	<b
