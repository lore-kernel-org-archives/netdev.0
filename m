From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: chelsio: cxgb3: constify attribute_group
 structures.
Date: Mon, 10 Jul 2017 10:00:11 -0700
Message-ID: <1499706011.5468.15.camel@perches.com>
References: <0e68326e48e123c70191169a0c0da820237425ec.1499682619.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>, santosh@chelsio.com,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0e68326e48e123c70191169a0c0da820237425ec.1499682619.git.arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-07-10 at 16:04 +0530, Arvind Yadav wrote:
> attribute_groups are not supposed to change at runtime. All functions
> working with attribute_groups provided by <linux/sysfs.h> work
> with const attribute_group. So mark the non-const structs as const.

I think it's good you are doing all of these.

Instead of individually sending these patches, could you
please send a patch series for all of these attribute_group
patches with a cover letter at the same time?

That could make it easier for a trivial maintainer to apply
all of these at once and not get some applied and others
ignored or dropped on the floor.
