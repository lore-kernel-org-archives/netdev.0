From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 18:07:33 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040512220733.GB16658@fieldses.org>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu> <Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com> <20040512200305.GA16078@elte.hu> <Pine.LNX.4.58.0405121400360.11950@bigblue.dev.mdolabs.com> <20040512213913.GA16658@fieldses.org> <jevfj1nwe1.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Davide Libenzi <davidel@xmailserver.org>, Ingo Molnar <mingo@elte.hu>,
        Jeff Garzik <jgarzik@pobox.com>, Greg KH <greg@kroah.com>,
        Andrew Morton <akpm@osdl.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Schwab <schwab@suse.de>
Content-Disposition: inline
In-Reply-To: <jevfj1nwe1.fsf@sykes.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 12, 2004 at 11:55:18PM +0200, Andreas Schwab wrote:
> "J. Bruce Fields" <bfields@fieldses.org> writes:
> 
> > If gcc really optimizes that to just the identity function, then surely
> > that's a gcc bug?  Multiplication is left-associative, so i * 1000 /
> > 1000 = (i * 1000) / 1000, but (i * 1000) should be zero for any i
> > divisible by i^(sizeof(int) - 12).
> 
> Signed integer overflow is undefined in C, so the compiler is allowed to
> assume it does not happen.

Ugh, right, got it.--b.
