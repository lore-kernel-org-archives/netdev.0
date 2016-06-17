From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] mlx5: only register devlink when ethernet is available
Date: Fri, 17 Jun 2016 17:02:33 +0200
Message-ID: <51058521.f6SstSCt2o@wuerfel>
References: <20160615152816.2800830-1-arnd@arndb.de> <6330398.ySWGKSmLdn@wuerfel> <CALzJLG8BEivMg4h+=FcQ_7QFrZTRhRNsPgEH68WPKfmkguvNqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Eli Cohen <eli@mellanox.com>, Majd Dibbiny <majd@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	Fengguang Wu <fengguang.wu@intel.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALzJLG8BEivMg4h+=FcQ_7QFrZTRhRNsPgEH68WPKfmkguvNqA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, June 17, 2016 5:50:14 PM CEST Saeed Mahameed wrote:
> On Wed, Jun 15, 2016 at 11:50 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Wednesday, June 15, 2016 7:04:54 PM CEST Saeed Mahameed wrote:
> > Ok, I see. It would be nice if the process had a way to avoid build regressions
> > in linux-next, in particular if you already have a fix by the time a patch
> > that introduces a problem gets added.
> >
> 
> The reason we added this tree is to get 0-day testing but currently it
> makes some unwanted noise
> so we will remove it until we figure it out.

I think you can simply ask Fengguang Wu to add your git tree to the list
of trees he pulls from for the 0-day test bot.

> > Can you check if the fix for the second problem correctly removes the
> > unnecessary 64-bit division (as opposed to adding a call to div_s64()
> > or do_div()), and if it removes all traces of 'struct timespec' again?
> >
> 
> Yes, same thing, already fixed, will reply to that thread.

Ok, thanks for the confirmation!

	Arnd
