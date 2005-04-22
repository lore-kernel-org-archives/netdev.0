From: Wang Jian <lark@linux.net.cn>
Subject: Re: [RFC] QoS: frg queue (was [RFC] QoS: new per flow queue)
Date: Fri, 22 Apr 2005 20:04:38 +0800
Message-ID: <20050422200327.03E6.LARK@linux.net.cn>
References: <20050422115230.03E0.LARK@linux.net.cn> <20050422111100.GN577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050422111100.GN577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Thomas Graf,


On Fri, 22 Apr 2005 13:11:00 +0200, Thomas Graf <tgraf@suug.ch> wrote:

> 
> I had another look at your code and noticed the GFP_KERNEL masked
> kmalloc call in perflow_new_flow() called from perflow_enqueue(),
> you must change that to GFP_ATOMIC due to softirq context.

Acked. I will prepare another patch and put it online later.


-- 
  lark
