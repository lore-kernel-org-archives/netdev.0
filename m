From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
Date: Tue, 16 Jun 2015 10:06:56 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1506161006060.3496@east.gentwo.org>
References: <20150615155053.18824.617.stgit@devil> <20150615155256.18824.42651.stgit@devil> <20150616072328.GB13125@js1304-P5Q-DELUXE> <20150616112033.0b8bafb8@redhat.com> <CAAmzW4P4kHW4NJv=BFXye4bENv1L7Tdyhuwio3rm5j-3y-tE-g@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>,
    Linux Memory Management List <linux-mm@kvack.org>,
    Andrew Morton <akpm@linux-foundation.org>,
    Linux-Netdev <netdev@vger.kernel.org>,
    Alexander Duyck <alexander.duyck@gmail.com>
To: Joonsoo Kim <js1304@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CAAmzW4P4kHW4NJv=BFXye4bENv1L7Tdyhuwio3rm5j-3y-tE-g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Jun 2015, Joonsoo Kim wrote:

> > If adding these, then I would also need to add those on alloc path...
>
> Yes, please.

Lets fall back to the generic implementation for any of these things. We
need to focus on maximum performance in these functions. The more special
cases we have to handle the more all of this gets compromised.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
