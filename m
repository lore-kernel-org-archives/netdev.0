From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: 05 Apr 2005 12:11:35 -0400
Message-ID: <1112717495.1076.22.camel@jzny.localdomain>
References: <20050405202039.0250.LARK@linux.net.cn>
	 <1112705689.1088.209.camel@jzny.localdomain>
	 <20050405213023.0256.LARK@linux.net.cn>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
In-Reply-To: <20050405213023.0256.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Wang,

On Tue, 2005-04-05 at 10:18, Wang Jian wrote:

> I am not saying that we must use jenkins. We may use a less expensive
> hash function than jenkins, but better than & 0xFF.
> 

Sure; point is as long as it doesnt destroy the common use in place.

>Anyway, I have done userspace test for jhash. The following test 
> is done in a AMD Athlon 800MHz without other CPU load.
> 

No, the test i was asking for is to show distribution of the
hash not how long it took (which is also an ok test).

i.e if you fed the jenkins hash with 256 buckets - lets pick the number 1024 
samples of the data you showed earlier for how fwmark looks like,
how well would the result look like. 
And what if you fed it with something like 1024 incremental fwmark from 
say 1..1024?

cheers,
jamal
