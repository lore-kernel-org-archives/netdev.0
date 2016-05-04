From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH 3/3] net/mlx5e: don't build RFS without ethernet
Date: Wed, 4 May 2016 16:09:16 +0300
Message-ID: <CALzJLG9j6ZodwDToX8iuvNVKLoMoaM8V9w8cFR6jM-ktU0ynHg@mail.gmail.com>
References: <1462364774-3792510-1-git-send-email-arnd@arndb.de> <1462365155-3861405-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Matthew Finlay <matt@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462365155-3861405-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 4, 2016 at 3:32 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> The RFS acceleration support in mlx5 is enabled whenever CONFIG_RFS_ACCEL
> is in use. However, this fails if a user turns off CONFIG_MLX5_CORE_EN,
> because the rfs code now calls into the ethernet portion of the
> driver:
>
> ERROR: "mlx5e_destroy_flow_table" [drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.ko] undefined!
>

Hi Arnd,

We already posted a fix for this, please see "[PATCH net-next V1
01/12] net/mlx5e: Fix aRFS compilation dependency", and give us your
feedback.

Saeed.
