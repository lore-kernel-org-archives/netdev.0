From: David Miller <davem@davemloft.net>
Subject: Re: [net-next][PATCH v2 18/18] RDS: IB: add missing connection
 cache usage info
Date: Wed, 07 Dec 2016 12:36:42 -0500 (EST)
Message-ID: <20161207.123642.1553217272033137094.davem@davemloft.net>
References: <eac62d66-7a41-965d-8ecb-c2e4b651c39d@oracle.com>
        <20161207.120536.1153607792891600896.davem@davemloft.net>
        <6159757e-c799-ee7f-0ee0-c9b3534a4237@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6159757e-c799-ee7f-0ee0-c9b3534a4237@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Wed, 7 Dec 2016 09:20:17 -0800

> Newer/Updated tools which can parse this extra info in needs newer
> or an updated kernel which supports and populates these fields.
> 
> As mentioned, this particular option used only in verbose mode so
> am ok to drop this change if its still a concern.

What does the newer tool do on an older kernel if it doesn't see
the fields?  Does it check the size of the structure given back
to it, and conditionally handle the older vs. the newer layout?

It must do this.
