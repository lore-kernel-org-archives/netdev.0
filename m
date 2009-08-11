From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2 1/2] mm: export use_mm/unuse_mm to modules
Date: Tue, 11 Aug 2009 15:10:10 -0700
Message-ID: <20090811151010.c9c56955.akpm@linux-foundation.org>
References: <cover.1249992497.git.mst@redhat.com>
	<20090811212752.GB26309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
        kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu,
        linux-mm@kvack.org, hpa@zytor.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20090811212752.GB26309@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Aug 2009 00:27:52 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> vhost net module wants to do copy to/from user from a kernel thread,
> which needs use_mm (like what fs/aio has).  Move that into mm/ and
> export to modules.

OK by me.  Please include this change in the virtio patchset.  Which I
shall cheerfully not be looking at :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
