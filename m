From: Geliang Tang <geliangtang@gmail.com>
Subject: Re: [PATCH] net/mlx4: use rb_entry()
Date: Sun, 22 Jan 2017 22:42:25 +0800
Message-ID: <20170122144225.lvkakc7db7fs2xpq@ThinkPad>
References: <c6a809ea5820242a4ae126b03cdcd910a36e5cae.1484817152.git.geliangtang@gmail.com>
 <6c1c772de8f70113580dade04f89a377174d8c88.1484817025.git.geliangtang@gmail.com>
 <20170122074839.GD28570@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yishai Hadas <yishaih@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170122074839.GD28570@mtr-leonro.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 22, 2017 at 09:48:39AM +0200, Leon Romanovsky wrote:
> On Fri, Jan 20, 2017 at 10:36:57PM +0800, Geliang Tang wrote:
> > To make the code clearer, use rb_entry() instead of container_of() to
> > deal with rbtree.
> >
> > Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> > ---
> >  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> I don't understand completely the rationale behind this conversion.
> rb_entry == container_of, why do we need another name for it?
> 

There are several *_entry macros which are defined in kernel data
structures, like list_entry, hlist_entry, rb_entry, etc. Each of them is
just another name for container_of. We use different *_entry so that we
could identify the specific type of data structure that we are dealing
with.

-Geliang
