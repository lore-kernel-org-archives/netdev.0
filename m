From: Sam Leffler <sam@errno.com>
Subject: Re: [PATCH] pktgen: sprintf arg type warning
Date: Sat, 09 Oct 2004 10:30:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41682021.3080400@errno.com>
References: <20041008203027.643a2a97.rddunlap@osdl.org> <20041008221934.42a6bc7a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041008221934.42a6bc7a.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Fri, 8 Oct 2004 20:30:27 -0700
> "Randy.Dunlap" <rddunlap@osdl.org> wrote:
> 
> 
>>Fix sprintf arg type error (gcc 3.3.3), although it looks more like
>>a gcc problem than a kernel source code problem to me.
>>Doesn't matter on x86-32.  Fixes a warning on x86-64.
>>
>>net/core/pktgen.c:607: warning: long long unsigned int format, long unsigned int arg (arg 4)
> 
> 
> This won't fix the problem on sparc64 where u64 is an "unsigned long"
> So, just cast the thing to the type gcc wants "unsigned long long"
> 

Other systems have addressed this problem by extending printf with 
portable %formats.

	Sam
