From: Shawn Starr <shawn.starr@rogers.com>
Subject: Re: [2.6.10-rc1-bk5] e1000 broken badly on IBM T42
Date: Wed, 27 Oct 2004 17:41:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410271741.55039.shawn.starr@rogers.com>
References: <200410270033.22804.shawn.starr@rogers.com> <200410270521.56816.shawn.starr@rogers.com> <1098892310.8313.1.camel@krustophenia.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lee Revell <rlrevell@joe-job.com>, Pavel Machek <pavel@ucw.cz>
In-Reply-To: <1098892310.8313.1.camel@krustophenia.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Actually, there is a bug, when suspending the laptop its not storing the 
negotiated link status and resets to gigabit.

This looks to be a bug :-)

Shawn.

On October 27, 2004 11:51, Lee Revell wrote:
> On Wed, 2004-10-27 at 05:21 -0400, Shawn Starr wrote:
> > I should just answer it myself, restarting fixed the interface
> > negotiation 'blip'. Perhaps the driver somehow did not reset and retry
> > negotiation?
> >
> > That did look interesting though :)
>
> AIUI it's impossible to do 100% reliable autonegotiation with Ethernet.
> The best you can do is try to detect when you might have gotten it wrong
> and reset the interface.
>
> Lee
