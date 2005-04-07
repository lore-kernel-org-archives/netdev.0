From: Wang Jian <lark@linux.net.cn>
Subject: Re: [PATCH] [PKT_SCHED]: improve hashing performance of cls_fw
Date: Thu, 07 Apr 2005 22:03:33 +0800
Message-ID: <20050407220244.02D5.LARK@linux.net.cn>
References: <20050407212340.02D2.LARK@linux.net.cn> <20050407135240.GV26731@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050407135240.GV26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Thomas Graf,

Thanks :-)


On Thu, 7 Apr 2005 15:52:40 +0200, Thomas Graf <tgraf@suug.ch> wrote:

> * Wang Jian <20050407212340.02D2.LARK@linux.net.cn> 2005-04-07 21:31
> > Would you please test this case?
> > 
> > (0..1024) << 16
> > 
> > The old hash gives a 1024 depth bucket for this case.
> > 
> > And I am not sure if there is a bad range (0..n) << s which is mapped
> > into one bucket.
> 
> old hash (enum shift):
> empty buckets: 255 average chain length: 1024.000 min: 0 max: 1024
> 
> new hash (enum shift):
> empty buckets: 0 average chain length: 1.000 min: 1 max: 1



-- 
  lark
