From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: 3c509: constify pnp_device_id
Date: Wed, 16 Aug 2017 11:26:14 -0700 (PDT)
Message-ID: <20170816.112614.1895556827875971525.davem@davemloft.net>
References: <60c34272432b3411cd5d55728c62481e133f32a6.1502859040.git.arvind.yadav.cs@gmail.com>
        <9970265bdf2dd4c4dfbaf6690145d9726748b598.1502859040.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, dhowells@redhat.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9970265bdf2dd4c4dfbaf6690145d9726748b598.1502859040.git.arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Wed, 16 Aug 2017 10:25:59 +0530

> pnp_device_id are not supposed to change at runtime. All functions
> working with pnp_device_id provided by <linux/pnp.h> work with
> const pnp_device_id. So mark the non-const structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Applied.
