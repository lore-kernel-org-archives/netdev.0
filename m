From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: ethernet: remove incorrect __exit markups
Date: Thu, 02 Mar 2017 14:34:06 -0800 (PST)
Message-ID: <20170302.143406.1348849132445336690.davem@davemloft.net>
References: <20170302012447.GA39241@dtor-ws>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dmitry.torokhov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170302012447.GA39241@dtor-ws>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Date: Wed, 1 Mar 2017 17:24:47 -0800

> Even if bus is not hot-pluggable, devices can be unbound from the
> driver via sysfs, so we should not be using __exit annotations on
> remove() methods. The only exception is drivers registered with
> platform_driver_probe() which specifically disables sysfs bind/unbind
> attributes.
> 
> Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>

Applied, thank you.
