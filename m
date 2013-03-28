From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: 3.7.10 kernel crash
Date: Thu, 28 Mar 2013 08:35:47 -0400
Message-ID: <1364474147.3261.1.camel@thor.lan>
References: <CADpTngWo_c0MHNwYEFwSR_9KQrWKrOVgQSze+rZc4Ze9Rj2hsw@mail.gmail.com>
	 <CADpTngW8RTVX28bVJQe5tV_ccc+FNOJezeQbczXFudy+7bMRDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Fabio Coatti <fabio.coatti@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADpTngW8RTVX28bVJQe5tV_ccc+FNOJezeQbczXFudy+7bMRDQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[ +cc Matt Carlson, Michael Chan, netdev because this is a tg3-related oops]

On Thu, 2013-03-28 at 09:31 +0100, Fabio Coatti wrote:
> 2013/3/27 Fabio Coatti <fabio.coatti@gmail.com>:
> > Hi all,
> > we are experiencing crashes on some servers, right now running 3.7.10;
> > I've been able to get only screenshots from dying server that I
> > attached below. Probably we can exclude hardware issues, as it
> > happened on two different servers.
> 
> Further information: those crashes seems to happen only when the
> machine is heavily loaded (process, network and so on). We have seen
> this pattern several times.

I would recommend capturing the entire oops text (it will likely be
necessary anyway for someone to properly identify and fix the cause).

If the machine has a 2nd network port, then use netconsole on that
interface. If not, set up a serial console or try to get 50-line VGA
working.

Regards,
Peter Hurley
