From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ibm: ibmvnic: constify vio_device_id
Date: Thu, 17 Aug 2017 10:18:09 -0700 (PDT)
Message-ID: <20170817.101809.118916278042596088.davem@davemloft.net>
References: <b8393cdf646fae5ccbb64aab482c133fd54a7339.1502975929.git.arvind.yadav.cs@gmail.com>
        <b8393cdf646fae5ccbb64aab482c133fd54a7339.1502975929.git.arvind.yadav.cs@gmail.com>
        <74d0d08fe98bf52e122d027efdcd7f9811309325.1502975929.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tlfalcon@linux.vnet.ibm.com, benh@kernel.crashing.org,
        jallen@linux.vnet.ibm.com, mpe@ellerman.id.au,
        linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <74d0d08fe98bf52e122d027efdcd7f9811309325.1502975929.git.arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Thu, 17 Aug 2017 18:52:54 +0530

> vio_device_id are not supposed to change at runtime. All functions
> working with vio_device_id provided by <asm/vio.h> work with
> const vio_device_id. So mark the non-const structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Applied.
