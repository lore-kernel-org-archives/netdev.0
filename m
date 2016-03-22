From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v3 0/2] AF_VSOCK: Shrink the area influenced by
 prepare_to_wait
Date: Tue, 22 Mar 2016 16:19:16 -0400 (EDT)
Message-ID: <20160322.161916.402932899605112194.davem@redhat.com>
References: <1458662752-2415-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: labbott@fedoraproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: imbrenda@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57935 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751417AbcCVUTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 16:19:18 -0400
In-Reply-To: <1458662752-2415-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Date: Tue, 22 Mar 2016 17:05:50 +0100

> This patchset applies on net-next.
> 
> I think I found a problem with the patch submitted by Laura Abbott
> ( https://lkml.org/lkml/2016/2/4/711 ): we might miss wakeups.
> Since the condition is not checked between the prepare_to_wait and the
> schedule(), if a wakeup happens after the condition is checked but before
> the sleep happens, and we miss it. ( A description of the problem can be
> found here: http://www.makelinux.net/ldd3/chp-6-sect-2 ).
> 
> The first patch reverts the previous broken patch, while the second patch
> properly fixes the sleep-while-waiting issue.

Series applied, thanks for following up on this.
