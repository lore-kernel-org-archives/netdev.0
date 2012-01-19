From: David Lamparter <equinox@diac24.net>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 14:31:34 +0100
Message-ID: <20120119133134.GK2262734@jupiter.n2.diac24.net>
References: <201201191207.10207.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:34997 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753220Ab2ASNbn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 08:31:43 -0500
Content-Disposition: inline
In-Reply-To: <201201191207.10207.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2012 at 12:07:09PM +0100, Hans Schillstrom wrote:
> Closing of a namespace (container) can be delayed by ~ 2 minutes 
> due to tcp timers ex tcp time wait (and of cource other things too).
> 
> I think there should be some kind of "forced close" of the Network stack
> in ex free_nsproxy() 
> 
> A netns pre-close  callback might do the job....
> 
> Any ideas how to solve this ?

I'm interested in this too; right off I don't see a workable alternative
to your suggestion. Each subsystem will have to implement that callback
and release its references on the netns.


-David
