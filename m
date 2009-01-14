From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 4/4] virtio_net: Add a MAC filter table
Date: Wed, 14 Jan 2009 16:38:56 +0000
Message-ID: <1231951136.4944.305.camel@localhost.localdomain>
References: <1231881800.9095.189.camel@bling>
	 <1231928112.4944.292.camel@localhost.localdomain>
	 <1231950031.7109.307.camel@lappy>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1231950031.7109.307.camel@lappy>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-01-14 at 09:20 -0700, Alex Williamson wrote:
> > Also, no need for the extra variable or the case, is there?
> 
> Initially, that's what I thought too... but it doesn't work, I always
> got 0 on the backend.  I assume it has something to do with the memory
> segment mac_entries lives in as a static variable.

Bizarre - it'd be good to understand exactly why. Add a comment to that
effect, at least.

Cheers,
Mark.

