From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Mon, 13 Aug 2007 03:15:08 -0700
Message-ID: <200708130315.08382.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708130255.35828.phillips@phunq.net> <20070813100636.GL23758@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070813100636.GL23758@kernel.dk>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 August 2007 03:06, Jens Axboe wrote:
> On Mon, Aug 13 2007, Daniel Phillips wrote:
> > Of course not.  Nothing I said stops endio from being called in the
> > usual way as well.  For this to work, endio just needs to know that
> > one call means "end" and the other means "destroy", this is
> > trivial.
>
> Sorry Daniel, but your suggestions would do nothing more than uglify
> the code and design.

Pretty much exactly what was said about shrinking struct page, ask Bill.  
The difference was, shrinking struct page actually mattered whereas 
shrinking struct bio does not, and neither does expanding it by a few 
bytes.

Regards,

Daniel
