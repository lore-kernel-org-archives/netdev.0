From: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Subject: Re: WiMAX linux firmware pull request
Date: Tue, 28 Sep 2010 21:27:45 -0700
Message-ID: <1285734465.3136.339.camel@localhost.localdomain>
References: <1285699570.3136.307.camel@localhost.localdomain>
	 <1285728768.814.74.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "wimax@linuxwimax.org" <wimax@linuxwimax.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4797 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751087Ab0I2EdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 00:33:07 -0400
In-Reply-To: <1285728768.814.74.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-09-28 at 19:52 -0700, David Woodhouse wrote: 
> On Tue, 2010-09-28 at 11:46 -0700, Inaky Perez-Gonzalez wrote:    
> >    The 1.3 version is purged as it is not supported anymore.
> 
> Not supported by newer kernels? Or "if you are using something that
> requires the 1.3 firmware, you can just fuck off and die", along the
> lines of what we say to users of the 2.4 kernel?

Along those lines -- basically 1.3 was an experimental release and if
you have that firmware, you won't be able to connect to anything than a
very specific test setup in a lab. The code is still there because it is
just two perfectly isolated paths (if curious, check what goes with the
i2400m_le_v1_3() test) that I forgot to excise out.

> We shouldn't drop stuff from linux-firmware.git until there really is
> *no* reason to need it any more. We shouldn't force people to keep
> linux-firmware in step with their kernel; they should always be able to
> use the latest.

Yes, I am aware of that. That's why 1.4 is kept there -- 1.3 is an
special case because as I said above, it can't be used in the real world
of WiMAX, 

> When I get home from Tokyo I'll be working on a way to specify min/max
> kernel versions for each firmware image, along with a 'make install'
> target which lets you say "drop anything which is only relevant to
> kernels < 2.6.35' or whatever.

That looks pretty sensible :)



