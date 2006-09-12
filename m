From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [RFC] Alternate WE-21 support (core API)
Date: Tue, 12 Sep 2006 09:17:37 -0700
Message-ID: <20060912161737.GB3536@bougret.hpl.hp.com>
References: <1157031138.16040.17.camel@ux156> <20060831135112.GA6097@jm.kir.nu> <1157032805.16040.21.camel@ux156> <20060906205538.GA29767@tuxdriver.com> <20060906213053.GA21719@bougret.hpl.hp.com> <20060908142913.GD23852@tuxdriver.com> <20060908161345.GA27036@bougret.hpl.hp.com> <1157965694.2811.3.camel@ux156> <20060911162608.GA31459@bougret.hpl.hp.com> <1158050637.2854.16.camel@ux156>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:14819 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S1030252AbWILQS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 12:18:27 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1158050637.2854.16.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 12, 2006 at 10:43:57AM +0200, Johannes Berg wrote:
> 
> > But there are bits left and right, so
> > more inspection of drivers would be needed. For example, wavelan and
> > netwave are using encryption key sizes which are not compatible with
> > 802.11.
> 
> Hmm, interesting. Will need to think about that for a bit. The whole key
> management stuff is fairly hairy, even more so in wpa/wpa2.

	I was initially very negative towards the WPA API (WPA +
extended scan), because it's so complex. I went back and forth with
Jouni trying to simplify it, but we did not manage to gain much. I
trust that Jouni did the best he could, that's just the nature of the
beast.

	I was thinking of the WE -> nl80211 compatibility. It's pretty
trivial to do as far as WE is concerned, you just need to hack
get_handler() to return the nl80211 handler. Or, if you don't like a
single handler, you could have one wrapper per ioctl, which is even
easier.
	Do you have a recent version of your code so that I can see
how it can hook on your side ? I think we could put the generic
mechanism in place early so that people can add specifics as they need
them.

> johannes

	Have fun...

	Jean
