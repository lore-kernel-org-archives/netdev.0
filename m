From: "David S. Miller" <davem@redhat.com>
Subject: Re: Patch: IPv6/AMD64: bug in net/ipv6/ndisc.c
Date: Thu, 29 Jan 2004 15:39:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040129153953.3dd2cd23.davem@redhat.com>
References: <20040129221538.J24747@fi.muni.cz>
	<20040130.083743.20740540.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: kas@informatics.muni.cz, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040130.083743.20740540.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 30 Jan 2004 08:37:43 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> For long term solution, I think it is better to store timing variables 
> in "unsinged long" type instead of int. 

I think this is the only fix to even consider, even in the short term.
The macro suggested is just too much of a hack. :)

We can just ignore the silly warning until we are able to find time
to do the correct fix.
