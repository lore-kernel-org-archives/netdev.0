From: Samuel Ortiz <samuel.ortiz@nokia.com>
Subject: Re: wireless: recap of current issues (configuration)
Date: Mon, 16 Jan 2006 21:07:52 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0601162056261.17348@irie>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com>
 <20060113213011.GE16166@tuxdriver.com> <20060113221935.GJ16166@tuxdriver.com>
 <1137191522.2520.63.camel@localhost> <20060114011726.GA19950@shaftnet.org>
 <43C97605.9030907@pobox.com> <20060115152034.GA1722@shaftnet.org>
 <43CAA853.8020409@errno.com> <20060116172817.GB8596@shaftnet.org>
Reply-To: samuel.ortiz@nokia.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sam Leffler <sam@errno.com>, Jeff Garzik <jgarzik@pobox.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751143AbWAPTKL@vger.kernel.org>
To: ext Stuffed Crust <pizza@shaftnet.org>
In-Reply-To: <20060116172817.GB8596@shaftnet.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Jan 2006, ext Stuffed Crust wrote:

> Background scanning, yes -- but there are all sorts of different
> thresholds and types of 'scanning' to be done, depending on how
> disruptive you are willing to be, and how capable the hardware is.  Most
> thin MACs don't filter out foreign BSSIDs on the same channel when
> you're joined, which makes some things a lot easier.
That is true, thin MACs usually don't filter beacons on the same channel.
But in some cases (mainly power saving), you really want to avoid
receiving useless beacons and having the host woken up for each of them.
You may even want to not receive all the useful ones (the ones coming from
the AP you're joined with) if your softmac allows that.
This kind of beacon filtering is a big power saver, which is one of the
most important requirement for some platforms (phones, PDA, etc...).

Cheers,
Samuel.
