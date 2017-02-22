From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlogic: netxen: constify bin_attribute structures
Date: Wed, 22 Feb 2017 15:40:06 -0500 (EST)
Message-ID: <20170222.154006.76706389880601263.davem@davemloft.net>
References: <1487702868-14161-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, rahul.verma@cavium.com,
        manish.chopra@cavium.com, Dept-GELinuxNICDev@cavium.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487702868-14161-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Wed, 22 Feb 2017 00:17:48 +0530

> Declare bin_attribute structures as const as they are only passed as an
> arguments to the functions device_remove_bin_file and
> device_create_bin_file. These function arguments are of type const, so
> bin_attribute structures having this property can be made const too.
> Done using Coccinelle:
 ...
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Also applied, thanks.
