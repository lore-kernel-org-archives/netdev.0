From: Greg KH <greg@kroah.com>
Subject: Re: Mis-backport in af_unix patch for Linux 3.10.95
Date: Sun, 24 Jan 2016 13:40:59 -0800
Message-ID: <20160124214059.GA9841@kroah.com>
References: <CAJLwaKa3vMzRnTt+JL7msQ33HZk_Jp+xMjOteBYCad46u15hKg@mail.gmail.com>
 <20160124083142.GA14045@1wt.eu>
 <CAJLwaKb=uvay2Ht0-UbZzF03QmjwaZOVeJ+N+hTgSKbh61PJnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, stable@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Sultan Qasim <sultanqasim@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJLwaKb=uvay2Ht0-UbZzF03QmjwaZOVeJ+N+hTgSKbh61PJnA@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 24, 2016 at 11:16:25AM -0500, Sultan Qasim wrote:
> Hello,
> 
> Thank you very much for the warm welcome :-)
> 
> You're right, the noblock variable is used elsewhere in the stream
> receive function, so nothing is needed there after the interruptible
> logic is restored for the dgram function.
> 
> Your patch looks good to me. I had picked the Linux 3.12.52 version of
> the patch (where the interruptible locking was removed from the right
> place in the stream receive function) onto my 3.10 kernel branch a
> couple weeks ago and it has been working fine for me.

Great, thanks for reviewing and letting us know about this, I've queued
Willy's patch up now for inclusion in the next 3.10-stable release.

greg k-h
