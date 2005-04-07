From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [PKT_SCHED]: improve hashing performance of cls_fw
Date: Thu, 7 Apr 2005 15:52:40 +0200
Message-ID: <20050407135240.GV26731@postel.suug.ch>
References: <1112872055.1117.123.camel@jzny.localdomain> <20050407130925.GU26731@postel.suug.ch> <20050407212340.02D2.LARK@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
Content-Disposition: inline
In-Reply-To: <20050407212340.02D2.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Wang Jian <20050407212340.02D2.LARK@linux.net.cn> 2005-04-07 21:31
> Would you please test this case?
> 
> (0..1024) << 16
> 
> The old hash gives a 1024 depth bucket for this case.
> 
> And I am not sure if there is a bad range (0..n) << s which is mapped
> into one bucket.

old hash (enum shift):
empty buckets: 255 average chain length: 1024.000 min: 0 max: 1024

new hash (enum shift):
empty buckets: 0 average chain length: 1.000 min: 1 max: 1
