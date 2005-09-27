From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH] sys_sendmsg() alignment bug fix
Date: Mon, 26 Sep 2005 21:59:34 -0600
Message-ID: <1127793575.25276.14.camel@localhost.localdomain>
References: <1127764921.6529.60.camel@tdi>
	 <2cd57c90050926204022fb22ca@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750867AbVI0D7m@vger.kernel.org>
To: Coywolf Qi Hunt <coywolf@gmail.com>
In-Reply-To: <2cd57c90050926204022fb22ca@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2005-09-27 at 11:40 +0800, Coywolf Qi Hunt wrote:
> On 9/27/05, Alex Williamson <alex.williamson@hp.com> wrote:
> >    The patch below adds an alignment attribute to the buffer used in
> > sys_sendmsg().  This eliminates an unaligned access warning on ia64.
> 
> Is this a warning fix or bug fix?

  Guess I'd have to classify it as a warning fix.  ia64 is fairly
verbose about unaligned accesses by default, so the warning is printed
out runtime.

	Alex
