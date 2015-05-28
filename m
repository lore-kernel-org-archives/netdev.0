From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] core: Convert the function process_ipcsec to the,
 return type bool
Date: Wed, 27 May 2015 18:47:52 -0700
Message-ID: <1432777672.2846.190.camel@perches.com>
References: <1432775694-30144-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.ne, brouer@redhat.com, edumazet@google.com,
	ast@plumgrid.com, sd@queasysnail.net,
	elfring@users.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432775694-30144-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-05-27 at 21:14 -0400, Nicholas Krause wrote:
> This makes the function,process_ipsec have a return true
> of bool now due to only returning 1 or 0. In additon this
> changes this function's return statements to return true
> and false rather then 1 and 0 respectfully.

The patch subject title and the grammar in the commit message
could be improved, but other than that, it seems OK to me.

I would have written something like:

Subject: [PATCH] pktgen: Convert return type of process_ipsec to bool

It's used as a bool function, make it so.
Convert the return 1/0 to return true/false too.

Signed-off-by: etc...
