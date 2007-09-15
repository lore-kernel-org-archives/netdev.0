From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Sat, 15 Sep 2007 16:34:18 +0400
Message-ID: <20070915123418.GB25752@2ka.mipt.ru>
References: <20070914185429.GA9439@2ka.mipt.ru> <46EADC02.9070409@garzik.org> <170fa0d20709141954m4cff4650pa3b2bfd347e23f74@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Mike Snitzer <snitzer@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <170fa0d20709141954m4cff4650pa3b2bfd347e23f74@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mike.

On Fri, Sep 14, 2007 at 10:54:56PM -0400, Mike Snitzer (snitzer@gmail.com) wrote:
> This distributed storage is very much needed; even if it were to act
> as a more capable/performant replacement for NBD (or MD+NBD) in the
> near term.  Many high availability applications don't _need_ all the
> additional complexity of a full distributed filesystem.  So given
> that, its discouraging to see you trying to gently push Evgeniy away
> from all the promising work he has published.
> 
> Evgeniy, please continue your current work.

Thanks Mike, I work on this and will until feel it is completed.

Distributed filesystem is a logical continuation of the whoe idea of
storing data on the several remote nodes - DST and FS must exist
together for the maximum performance, but that does not mean that block
layer itself should be abandoned. As you probably noticed from my mail
to Jeff, distributed storage was originally part of the overall
filesystem design.

-- 
	Evgeniy Polyakov
