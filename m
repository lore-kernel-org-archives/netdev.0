From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH v9 00/16] Provide a zero-copy method on KVM
 virtio-net.
Date: Tue, 10 Aug 2010 18:43:13 -0700
Message-ID: <1281490993.3391.25.camel@localhost.localdomain>
References: <1281086624-5765-1-git-send-email-xiaohui.xin@intel.com>
	 <1281489804.3391.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:38126 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756918Ab0HKBnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Aug 2010 21:43:40 -0400
In-Reply-To: <1281489804.3391.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-10 at 18:23 -0700, Shirley Ma wrote:
> Also I found some vhost performance regression on the new
> kernel with tuning. I used to get 9.4Gb/s, now I couldn't get it. 

I forgot to mention the kernel I used 2.6.36 one. And I found the native
host BW is limited to 8.0Gb/s, so the regression might come from the
device driver not vhost.

Shirley



