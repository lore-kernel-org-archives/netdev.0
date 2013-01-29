From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Web10g TCP statistics patch - mainlining into kernel?
Date: Tue, 29 Jan 2013 17:49:15 +0000
Message-ID: <1359481755.4144.4.camel@bwh-desktop.uk.solarflarecom.com>
References: <18855.1359138716@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<web10g-user@web10g.org>
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <18855.1359138716@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-01-25 at 13:31 -0500, Valdis Kletnieks wrote:
[...]
> it's a zero-hit thing for people who don't choose to configure
> it into their kernel.
[...]

People with high-overhead changes always say this, but before long
distributions will be expected to enable it and then everyone pays the
price.  So I think you'll have to work on limiting the run-time overhead
when it's enabled at compile time but the user doesn't care about it.
Possibly it can be a run-time option?  (I haven't looked at the code and
don't expect to have time to do so.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
