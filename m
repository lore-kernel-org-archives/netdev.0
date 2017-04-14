From: Jens Axboe <axboe@fb.com>
Subject: Re: [PATCH block-tree] net: off by one in inet6_pton()
Date: Fri, 14 Apr 2017 14:09:30 -0600
Message-ID: <fa3631c5-8f5a-1d45-0968-33a4219aab24@fb.com>
References: <20170413194231.GD591@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Wei Tang <tangwei@cmss.chinamobile.com>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        <netdev@vger.kernel.org>, <linux-block@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sagi Grimberg <sagi@grimberg.me>
Return-path: <linux-block-owner@vger.kernel.org>
In-Reply-To: <20170413194231.GD591@mwanda>
Sender: linux-block-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/13/2017 01:42 PM, Dan Carpenter wrote:
> If "scope_len" is sizeof(scope_id) then we would put the NUL terminator
> one space beyond the end of the buffer.

Added, thanks Dan.

-- 
Jens Axboe
