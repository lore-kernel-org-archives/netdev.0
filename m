From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]Add new IPv6 MIBs counters support through netlink
Date: Wed, 26 May 2004 17:01:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526170140.4668dc21.davem@redhat.com>
References: <20040527.080828.06774575.yoshfuji@linux-ipv6.org>
	<OFA97F4753.DC8C93AD-ON87256EA0.0080DAAB-07256EA0.00814B08@us.ibm.com>
	<20040527.085812.33823249.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: xma@us.ibm.com, mashirle@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040527.085812.33823249.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 May 2004 08:58:12 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> > All the counters not just IP will be eventually 64 bits. We can fix it 
> > later. And 
> > if we implement 64 counters here, there is performance issue on some 
> > architectures which don't support atmoic 64 for 32 bit platform.
> 
> I strongly do not want to change interface twice to support these new
> statistics.

As a side note, I am worried about investing so much effort and
expense if by the time we make 64-bit atomic counters work acceptably
on 32-bit platforms we are all running Opteron machines :-)
