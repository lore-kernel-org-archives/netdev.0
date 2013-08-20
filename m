From: Borislav Petkov <bp@alien8.de>
Subject: Re: 3.11-rc6 genetlink locking fix offends lockdep
Date: Tue, 20 Aug 2013 11:04:48 +0200
Message-ID: <20130820090448.GB13078@pd.tnic>
References: <alpine.LNX.2.00.1308182143370.906@eggly.anvils>
 <1376899214.14734.6.camel@jlt4.sipsolutions.net>
 <5211FAB3.7080400@huawei.com>
 <1376911362.14734.11.camel@jlt4.sipsolutions.net>
 <alpine.LNX.2.00.1308191147350.1505@eggly.anvils>
 <1376987338.13829.7.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Hugh Dickins <hughd@google.com>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Otcheretianski, Andrei" <andrei.otcheretianski@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1376987338.13829.7.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 20, 2013 at 10:28:58AM +0200, Johannes Berg wrote:
> Something like the patch below, perhaps? Completely untested so far.

Yeah, this one seems to fix it here (I was seeing the same lockdep splat
as Hugh).

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
