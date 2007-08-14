From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Tue, 14 Aug 2007 04:35:43 -0700
Message-ID: <200708140435.44979.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708140413.12530.phillips@phunq.net> <20070814113039.GA20780@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from phunq.net ([64.81.85.152]:40606 "EHLO moonbase.phunq.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752592AbXHNLfr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 07:35:47 -0400
In-Reply-To: <20070814113039.GA20780@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 14 August 2007 04:30, Evgeniy Polyakov wrote:
> > And it will not solve the deadlock problem in general.  (Maybe it
> > works for your virtual device, but I wonder...)  If the virtual
> > device allocates memory during generic_make_request then the memory
> > needs to be throttled.
>
> Daniel, if device process bio by itself, it has a limit and thus it
> will wait in generic_make_request()

What will make it wait?

