From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: select() doesn't respect SO_RCVLOWAT ?
Date: Mon, 14 Mar 2005 13:24:24 +0000
Message-ID: <1110806662.15927.108.camel__6071.77234855971$1110807292$gmane$org@localhost.localdomain>
References: <Pine.LNX.4.61.0503101645190.29442@shang.nevis.columbia.edu>
	 <1110568180.17740.69.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0503111434040.30914@shang.nevis.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Resent-Message-Id: <20050314.223332.28902097.yoshfuji@wide.ad.jp>
To: Felix Matathias <felix@nevis.columbia.edu>
In-Reply-To: <Pine.LNX.4.61.0503111434040.30914@shang.nevis.columbia.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Gwe, 2005-03-11 at 20:26, Felix Matathias wrote:
> Dear Alan,
> 
> I am positive. I can setsockopt, and then, getsockopt returns the value 
> that I requested.

Ok I misremembered - its SNDLOWAT that is locked to one in Linux.

> Stevens very clearly states that SO_RCVLOWAT has a direct impact on 
> select() and I assumed that this would be the case for Linux.
> What is the rationale for not complying with that ? Is it the micromanagement
> of select() that you dislike ? Isn't a significant reduction in the
> amount of read operations a real gain in high speed networking ?

I believe since we implement SO_SNDLOWAT that its a bug. Stevens and
1003.1g both agree with your expectations. The right list is probably
netdev@oss.sgi.com however.

Alan

