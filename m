From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH kernel] Revert "net/mlx4_core: Set UAR page size to
 4KB regardless of system page size"
Date: Tue, 15 Mar 2016 08:29:11 -0700
Message-ID: <20160315152911.GA21139@infradead.org>
References: <1458037148-4475-1-git-send-email-aik@ozlabs.ru>
 <CAJ3xEMhxUuQj+E00fa-tEKz+dVzDqFspC80Z=k7UPZpOP30H3g@mail.gmail.com>
 <20160315121832.GA4741@infradead.org>
 <CAJ3xEMg5fq3Z2VH_qDjsFmTzhCibAGiXT9oEddEKbwktvSYSQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Alexey Kardashevskiy <aik@ozlabs.ru>,
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
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJ3xEMg5fq3Z2VH_qDjsFmTzhCibAGiXT9oEddEKbwktvSYSQQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2016 at 04:23:33PM +0200, Or Gerlitz wrote:
> Let us check. I was under (the maybe wrong) impression, that before this
> patch both PF/VF drivers were not operative on some systems, so on those
> systems it's fair to require the VF driver to be patched too.

To me it sounds like the system worked before. Alexey, can you confirm?
