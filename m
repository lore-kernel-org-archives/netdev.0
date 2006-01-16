From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: wireless: recap of current issues (configuration)
Date: Mon, 16 Jan 2006 22:24:41 +0000
Message-ID: <1137450281.15553.87.camel@localhost.localdomain>
References: <20060113212605.GD16166@tuxdriver.com>
	 <20060113213011.GE16166@tuxdriver.com>
	 <20060113221935.GJ16166@tuxdriver.com> <1137191522.2520.63.camel@localhost>
	 <20060114011726.GA19950@shaftnet.org> <43C97605.9030907@pobox.com>
	 <20060115152034.GA1722@shaftnet.org>
	 <Pine.LNX.4.58.0601152038540.19953@irie>
	 <20060116170951.GA8596@shaftnet.org>
	 <Pine.LNX.4.58.0601162020260.17348@irie>
	 <20060116190629.GB5529@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel.ortiz@nokia.com>,
	ext Stuffed Crust <pizza@shaftnet.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751224AbWAPWXF@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060116190629.GB5529@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Llu, 2006-01-16 at 14:06 -0500, John W. Linville wrote:
> If regulators come down on someone, it seems like common sense
> that they would be more lenient on mobile stations complying with a
> misconfigured AP than they would be with a mobile station ignoring a
> properly configured AP?  I know expecting common sense from government
> regulators is optimistic, but still... :-)

I can't guess on the subject of US regulators but for the UK experience
in other communities (eg amateur radio), and public statements indicate
that their high priorities are interference with emergency services and
the like. 

Concerns of direct relevance are
- transmitting on unlicensed frequencies (and 802.11 channel allocations
are dependant on nation - even within the EU)
- power violation
- anything else causing interference to other legitimate users at a
radio level

I would expect equipment to honour the subset of configurations that
meet BOTH the regulatory domain the system believes it exists within
(which may change dynamically!) AND the AP advertisement.

If I have told my equipment to obey UK law I expect it to do so. If I
hop on the train to France and forget to revise my configuration I'd
prefer it also believed the APs

Alan
