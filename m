From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sun, 27 Feb 2005 22:53:42 +0000
Message-ID: <42224F76.9000602@phekda.gotadsl.co.uk>
References: <42208D83.80803@phekda.gotadsl.co.uk> <200502261132.29261.jdmason@us.ibm.com> <4220B9C6.1010106@pobox.com> <20050226181213.GA13230@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Jon Mason <jdmason@us.ibm.com>,
        netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050226181213.GA13230@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Thanks for reviewing, Francois, Jon & Jeff!

Francois Romieu wrote:
[snip]
> Btw I'd simply remove the 'work' variable and schedule in an interruptible
> way until the dump is done.

OK, that will take me a bit longer to code. ;)

> BUG() is a bit exagerated imho.

It seems like a pretty good way of avoiding a buffer overrun to me. 
E.g.: you copy an extra statistic in rtl8169_get_ethtool_stats(), but 
forget to update the stats length. Is it not better to crash early, than 
encounter random behaviour later?

I can put an #ifdef RTL8169_DEBUG / #endif around it, if you'd be happier.

Thanks, bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
