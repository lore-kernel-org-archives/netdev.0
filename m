From: Samuel Ortiz <samuel.ortiz@nokia.com>
Subject: Re: wireless: recap of current issues (configuration)
Date: Mon, 16 Jan 2006 20:51:31 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0601162020260.17348@irie>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com>
 <20060113213011.GE16166@tuxdriver.com> <20060113221935.GJ16166@tuxdriver.com>
 <1137191522.2520.63.camel@localhost> <20060114011726.GA19950@shaftnet.org>
 <43C97605.9030907@pobox.com> <20060115152034.GA1722@shaftnet.org>
 <Pine.LNX.4.58.0601152038540.19953@irie> <20060116170951.GA8596@shaftnet.org>
Reply-To: samuel.ortiz@nokia.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751131AbWAPSxg@vger.kernel.org>
To: ext Stuffed Crust <pizza@shaftnet.org>
In-Reply-To: <20060116170951.GA8596@shaftnet.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Jan 2006, ext Stuffed Crust wrote:

> On Sun, Jan 15, 2006 at 09:05:33PM +0200, Samuel Ortiz wrote:
> > Regarding 802.11d and regulatory domains, the stack should also be able to
> > stick to one regulatory domain if asked so by userspace, whatever the APs
> > around tell us.
>
> ...and in doing so, violate the local regulatory constraints.  :)
The other option is to conform to whatever the AP you associate with
advertises. In fact, this is how it should be done according to 802.11d.
Unfortunately, this doesn't ensure local regulatory constraints compliance
unless you expect each and every APs to do the Right Thing ;-)


> Allowing
> the user to change the regulatory domain at will.. is a rather fuzzy
> legal area, to say the least.
IMHO, strictly sticking to 802.11d is also somehow legally fuzzy as you're
as legal as the network you're joining.

Cheers,
Samuel.
