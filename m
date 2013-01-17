From: Cong Wang <amwang@redhat.com>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and
 <linux/in6.h>
Date: Thu, 17 Jan 2013 11:40:46 +0800
Message-ID: <1358394046.3855.10.camel@cr0>
References: <201301161205.04502.vapier@gentoo.org>
	 <201301161228.42592.vapier@gentoo.org>
	 <20130116.135959.90676245194307972.davem@davemloft.net>
	 <201301161422.19202.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
        libc-alpha@sourceware.org, yoshfuji@linux-ipv6.org, tmb@mageia.org,
        eblake@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, libvirt-list@redhat.com, tgraf@suug.ch,
        schwab@suse.de, carlos@systemhalted.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <libc-alpha-return-36354-glibc-alpha=m.gmane.org@sourceware.org>
In-Reply-To: <201301161422.19202.vapier@gentoo.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-01-16 at 14:22 -0500, Mike Frysinger wrote:
> 
> but this is still too vague.  what headers/definitions do people want to see 
> simultaneously included ?  changes would be needed on both sides (kernel & C 
> library).
> 

Hi, Mike,

Please take a look at my first email in this thread. The user
application includes <linux/if_bridge.h> and <netinet/in.h>.

<linux/if_bridge.h> uses struct_in6 but doesn't include <linux/in6.h>
(this is my bad, sorry), an obvious fix is just including <linux/in6.h>.
But this immediately breaks applications which include
<linux/if_bridge.h> and <netinet/in.h>, just as what Thomas reported.

And if_bridge.h is kernel-specific, there is no corresponding glibc one,
so you can't blame applications which include both of them.

Thanks.
