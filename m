From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: bind and O_NONBLOCK
Date: Sat, 22 Sep 2007 20:59:38 +0400
Message-ID: <20070922165938.GA11234@2ka.mipt.ru>
References: <46F35DD9.4000909@redhat.com> <20070922161414.GA29637@2ka.mipt.ru> <46F540F2.1090109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Alan Cox <alan@redhat.com>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35067 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672AbXIVRAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2007 13:00:13 -0400
Content-Disposition: inline
In-Reply-To: <46F540F2.1090109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 22, 2007 at 09:21:06AM -0700, Ulrich Drepper (drepper@redhat.com) wrote:
> Evgeniy Polyakov wrote:
> > So, did I understand you correctly, that you want to introduce network
> > AIO here? (for example on behalf of work queue or something else?)
> 
> See Alan's mail.  All this was his proposal, I just got it accepted
> upstream.
> 
> The problem to solve is if you have a distributed network port set.
> Apparently NetBIOS has it but I could also imagine this to be useful in
> cluster implementations which have to appear as one machine.  In this
> case, before binding to a given port, you have to make sure no other
> machine already handles this port.

Yes, to handle bind conflict in some or another way.
Could you point to the original Alan's proposal, I only found short note
(as in you original mail) at opengroup.org and failed to correctly
googlify it in the web.

-- 
	Evgeniy Polyakov
