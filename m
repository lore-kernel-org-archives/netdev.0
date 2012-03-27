From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Tue, 27 Mar 2012 20:33:50 +0200
Message-ID: <20120327183349.GB3878@netboy.at.omicron.at>
References: <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
 <20120321170003.GA5533@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
 <CAAsGZS6QuMJoXz8mmqZsgfTF2ykRz6KG_nCoPBBkTA4z3idoGA@mail.gmail.com>
 <20120322064107.GB2182@netboy.at.omicron.at>
 <CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
 <02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
 <CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
 <20120324065147.GB2201@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB580DC1C2@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chetan loke <loke.chetan@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:60965 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755527Ab2C0SeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 14:34:08 -0400
Received: by wgbdr13 with SMTP id dr13so200737wgb.1
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 11:34:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB580DC1C2@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 26, 2012 at 08:51:28PM +0000, Keller, Jacob E wrote:
> 
> This is about a case where the user does something stupid. (runs the ioctls too
> fast). It appears that your answer is something like "The user did something
> stupid, we shouldn't care". My answer is, "we should do what we can to prevent
> this."

No matter how much you optimize your driver (or library or whatever),
there is always some user load that will kill your performance.

The locking is need for data integrity. The code path in the lock is
short. I doubt there is any serious performance issue here.

Richard
