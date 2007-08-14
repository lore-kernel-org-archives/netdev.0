From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Block device throttling [Re: Distributed storage.]
Date: Tue, 14 Aug 2007 05:54:16 -0700
Message-ID: <200708140554.18897.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708140532.31378.phillips@phunq.net> <20070814124656.GB10446@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070814124656.GB10446@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 14 August 2007 05:46, Evgeniy Polyakov wrote:
> > The throttling of the virtual device must begin in
> > generic_make_request and last to ->endio.  You release the throttle
> > of the virtual device at the point you remap the bio to an
> > underlying device, which you have convinced yourself is ok, but it
> > is not.  You seem to miss the fact that whatever resources the
> > virtual device has allocated are no longer protected by the
> > throttle count *of the virtual device*, or you do not
>
> Because it is charged to another device.

Great.  You charged the resource to another device, but you did not 
limit the amount of resources that the first device can consume.  Which 
misses the whole point.

Regards,

Daniel
