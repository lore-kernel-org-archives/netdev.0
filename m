From: Wang Jian <lark@linux.net.cn>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Tue, 05 Apr 2005 20:39:41 +0800
Message-ID: <20050405202039.0250.LARK@linux.net.cn>
References: <20050405190024.024D.LARK@linux.net.cn> <20050405121605.GM26731@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050405121605.GM26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Thomas Graf,


On Tue, 5 Apr 2005 14:16:05 +0200, Thomas Graf <tgraf@suug.ch> wrote:

> 
> What I'm worried about is that we lose the zero collisions behaviour
> for the most popular use case.

If a web interface is used to generate netfilter/tc rules that use
nfmark, then the above assumption is false. nfmark will be used
incrementally and wrapped back to 0 somewhere like process id. So zero
collision is not likely.

When linux's QoS control capability is widely used, such web interface
sooner or later comes into being.
 
> New idea: we make this configureable and allow 3 types of hash functions:
>  1) default as-is, perfect for marks 0..255
>  2) all bits taken into account (your patch)
>  3) bitmask + shift provided by the user just like
>     dsmark.
> 
> Thoughts?

Your suggestion is very considerable. But that needs some more work. And,
isn't that some bloated?


-- 
  lark
