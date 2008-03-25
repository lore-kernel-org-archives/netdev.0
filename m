From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Tue, 25 Mar 2008 10:55:18 -0400
Message-ID: <47E91256.3010000@garzik.org>
References: <m3prtzsszg.fsf@maximus.localdomain>	<m3tzj92xq6.fsf@maximus.localdomain> <m33aqedg0a.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756363AbYCYOzg@vger.kernel.org>
In-Reply-To: <m33aqedg0a.fsf@maximus.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> Hi,
> 
> I wrote:
> 
>> New synchronous PPP implementation for generic HDLC.
> 
> So are we leaving the generic-HDLC+PPP in broken state for 2.6.25,
> aren't we?
> 
> If we do, perhaps a "|| BROKEN" in drivers/net/wan/Kconfig would make
> sense? Any attempt to use it will cause kernel panic immediately (PPP
> with generic HDLC only; drivers using syncppp.c directly are not
> affected). I can make that trivial Kconfig patch of course.

In your original email you said

	I guess it should go into 2.6.25, not sure about "stable"
	series. I will appreciate any feedback, review and/or test
	results.

At the time of the posting 2.6.25-rc6 had already been released, which 
seems like an inappropriate time for all that new code, which has been 
given so little exposure to real world testing.

Certainly your original message said PPP panics, but without even 
minimal testing how do we know that your new code doesn't have equally 
problematic issues?

So quite honestly a CONFIG_BROKEN patch might indeed be more appropriate 
since generic HDLC works with Frame Relay at least...

Comments?  IMO the current code is a known risk (PPP panic, FR works) 
whereas the new code is an unknown risk very late in 2.6.25-rc -- but 
with a good chance to make HDLC+PPP work again.

	Jeff
