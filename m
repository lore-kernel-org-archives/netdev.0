From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] net, ppp: Report correct error code if unit
 allocation failed
Date: Sun, 28 Nov 2010 11:33:43 -0800 (PST)
Message-ID: <20101128.113343.200360663.davem@davemloft.net>
References: <20101123214344.GB1839@lenovo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org,
	linux-ppp@vger.kernel.org, linux-kernel@vger.kernel.org
To: gorcunov@gmail.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20101123214344.GB1839@lenovo>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Wed, 24 Nov 2010 00:43:44 +0300

> Allocating unit from ird might return several error codes
> not only -EAGAIN, so it should not be changed and returned
> precisely. Same time unit release procedure should be invoked
> only if device is unregistering.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>

Looks good to me, applied, thanks Cyrill.
