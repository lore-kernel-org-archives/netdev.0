From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [Cocci] SmPL for automatic request_firmware_nowait() conversion
Date: Tue, 24 Jun 2014 02:32:29 +0200
Message-ID: <20140624003229.GE27687@wotan.suse.de>
References: <20140621015714.GX4841@wotan.suse.de> <20140621105205.GA31611@electric-eye.fr.zoreil.com> <20140623232107.GB27687@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cocci@systeme.lip6.fr,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140623232107.GB27687@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 24, 2014 at 01:21:07AM +0200, Luis R. Rodriguez wrote:
> On Sat, Jun 21, 2014 at 12:52:05PM +0200, Francois Romieu wrote:
> > Luis R. Rodriguez <mcgrof@suse.com> :
> I was actually in the hopes a suitable transormation can be designed
> to put a wait_for_completion() in say ndo_init(). I was looking to
> see if a tranformation can be generalized of course if the above
> observations on probe() is something desirable to be addressed.

And a really cool check would be to transform all those non fatal
request_firmware() calls to request_firmware_direct().

  Luis
