From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC PATCH kernel] Revert "net/mlx4_core: Set UAR page size to
 4KB regardless of system page size"
Date: Tue, 15 Mar 2016 16:23:33 +0200
Message-ID: <CAJ3xEMg5fq3Z2VH_qDjsFmTzhCibAGiXT9oEddEKbwktvSYSQQ@mail.gmail.com>
References: <1458037148-4475-1-git-send-email-aik@ozlabs.ru>
	<CAJ3xEMhxUuQj+E00fa-tEKz+dVzDqFspC80Z=k7UPZpOP30H3g@mail.gmail.com>
	<20160315121832.GA4741@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>,
	Huy Nguyen <huyn@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Paul Mackerras <paulus@samba.org>,
	Carol L Soto <clsoto@us.ibm.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Daniel Jurgens <danielj@mellanox.com>,
	Eli Cohen <eli@mellanox.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34857 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbcCOOXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 10:23:34 -0400
In-Reply-To: <20160315121832.GA4741@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 15, 2016 at 2:18 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Mar 15, 2016 at 12:40:06PM +0200, Or Gerlitz wrote:
>> "[..] Regarding backward compatibility in SR-IOV, if hypervisor has
>> this new code, the virtual OS must be updated. [...]"

> Which is broken, we can't break user or guest VM ABIs ever.

Let us check. I was under (the maybe wrong) impression, that before this
patch both PF/VF drivers were not operative on some systems, so on those
systems it's fair to require the VF driver to be patched too.

Or.
