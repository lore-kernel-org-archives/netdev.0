From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 10/10] virtio: enable endian checks for sparse builds
Date: Tue, 6 Dec 2016 23:30:21 -0800
Message-ID: <20161207073021.GA26970@infradead.org>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
 <1481038106-24899-11-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
        linux-kbuild@vger.kernel.org, Michal Marek <mmarek@suse.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Matt Mackall <mpm@selenic.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        David Airlie <airlied@linux.ie>,
        Gerd Hoffmann <kraxel@redhat.com>,
        Ohad Ben-Cohen <ohad@wizery.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Cornelia Huck <cornelia.huck@de.ibm.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "David S. Miller" <davem@davemloft.net>, Jens Axboe <axboe@fb.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Asias He <asias@redhat.com>, linux-crypto@vger.kernel.org,
        dri-devel@lists.freedesktop.org,
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481038106-24899-11-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 06, 2016 at 05:41:05PM +0200, Michael S. Tsirkin wrote:
> __CHECK_ENDIAN__ isn't on by default presumably because
> it triggers too many sparse warnings for correct code.
> But virtio is now clean of these warnings, and
> we want to keep it this way - enable this for
> sparse builds.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Nah.  Please just enable it globally when using sparse.  I actually
had a chat with Linus about that a while ago and he seemed generally
fine with it, I just didn't manage to actually do it..
