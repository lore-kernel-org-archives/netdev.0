From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4: use rb_entry()
Date: Sun, 22 Jan 2017 16:48:47 -0500 (EST)
Message-ID: <20170122.164847.331110749082525627.davem@davemloft.net>
References: <c6a809ea5820242a4ae126b03cdcd910a36e5cae.1484817152.git.geliangtang@gmail.com>
        <6c1c772de8f70113580dade04f89a377174d8c88.1484817025.git.geliangtang@gmail.com>
        <20170122074839.GD28570@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geliangtang@gmail.com, yishaih@mellanox.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: leon@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170122074839.GD28570@mtr-leonro.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leon@kernel.org>
Date: Sun, 22 Jan 2017 09:48:39 +0200

> I don't understand completely the rationale behind this conversion.
> rb_entry == container_of, why do we need another name for it?

Because it's an annotation.

Either you agree that the macro exists and it should be used in
every spot where those types are being used, or you don't and
therefore argue for the macro and it's usage completely.
