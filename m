From: Wang Jian <lark@linux.net.cn>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Tue, 05 Apr 2005 21:29:50 +0800
Message-ID: <20050405212711.0253.LARK@linux.net.cn>
References: <20050405202039.0250.LARK@linux.net.cn> <20050405125237.GN26731@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050405125237.GN26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Thomas Graf,


On Tue, 5 Apr 2005 14:52:37 +0200, Thomas Graf <tgraf@suug.ch> wrote:

> 
> > When linux's QoS control capability is widely used, such web interface
> > sooner or later comes into being.
> 
> That might be true but I will never ack on something that makes zero
> collision use of cls_fw impossible. I'm all for improving this but
> not at the cost of reduced performance for the most obvious use case
> of cls_fw.

Agree.

> 
> > Your suggestion is very considerable. But that needs some more work. And,
> > isn't that some bloated?
> 
> The shift + bitmask might be bloated and can be deferred a bit until
> someone comes up with this need. I can cook up a patch for this
> if you want, it's not much work.

I am glad that you are willing to help to hook them up. I really need
the new hashing way.


-- 
  lark
