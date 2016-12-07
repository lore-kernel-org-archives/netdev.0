From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [net-next][PATCH v2 18/18] RDS: IB: add missing connection cache
 usage info
Date: Wed, 7 Dec 2016 12:42:10 -0800
Message-ID: <79b08015-4f9c-50cd-edc5-b89a15627fef@oracle.com>
References: <eac62d66-7a41-965d-8ecb-c2e4b651c39d@oracle.com>
 <20161207.120536.1153607792891600896.davem@davemloft.net>
 <6159757e-c799-ee7f-0ee0-c9b3534a4237@oracle.com>
 <20161207.123642.1553217272033137094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161207.123642.1553217272033137094.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/7/2016 9:36 AM, David Miller wrote:

[...]

> What does the newer tool do on an older kernel if it doesn't see
> the fields?  Does it check the size of the structure given back
> to it, and conditionally handle the older vs. the newer layout?
>
> It must do this.
>
Right but the rds-tool doesn't handle it well and needs
to be fixed before this or any additional change in rds-info
structures. To handle the kernel struct size issues with its
user copy, there is a provision to probe kernel struct len
and then decide on layout buts its not used/implemented
in tools. The parsing comment I made is also not completely
accurate.

For now, I will drop this patch and submit it once the tools
code is fixed along with other used fields to handle both
layouts.

I should have checked the full compatibility matrix as you
commented. Sorry for oversight. Thanks for your comments Dave.

Regard,
Santosh
