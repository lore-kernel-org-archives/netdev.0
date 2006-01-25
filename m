From: Olaf Kirch <okir@suse.de>
Subject: Re: e100 oops on resume
Date: Wed, 25 Jan 2006 21:14:50 +0100
Message-ID: <20060125201450.GA15102@suse.de>
References: <20060124225919.GC12566@suse.de> <20060124232142.GB6174@inferi.kami.home> <20060125090240.GA12651@suse.de> <20060125121125.GH5465@suse.de> <4807377b0601251137r7621216byc47b03a3c634557c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Seyfried <seife@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751203AbWAYUOw@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Content-Disposition: inline
In-Reply-To: <4807377b0601251137r7621216byc47b03a3c634557c@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 25, 2006 at 11:37:40AM -0800, Jesse Brandeburg wrote:
> its an interesting patch, but it raises the question why does
> e100_init_hw need to be called at all in resume?  I looked back
> through our history and that init_hw call has always been there.  I
> think its incorrect, but its taking me a while to set up a system with
> the ability to resume.

I'll ask the folks here to give it a try tomorrow. But I suspect at
least some of it will be needed. For instance I assume you'll
have to reload to ucode when bringing the NIC back from sleep.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
