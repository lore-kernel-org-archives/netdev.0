From: david@lang.hm
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 21:47:25 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0808192138260.12859@asgard.lang.hm>
References: <20080819.140458.236030589.davem@davemloft.net>  <200808192315.48718.rjw@sisk.pl>  <alpine.LFD.1.10.0808191425050.3324@nehalem.linux-foundation.org>  <20080819.143556.245692295.davem@davemloft.net>
 <1219206013.7591.227.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	rjw@sisk.pl, akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lang.hm ([64.81.33.126]:50865 "EHLO bifrost.lang.hm"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbYHTErT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2008 00:47:19 -0400
In-Reply-To: <1219206013.7591.227.camel@violet.holtmann.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Aug 2008, Marcel Holtmann wrote:

>> And then there is the Bluetooth SCO change which I agree was
>> borderline and I should have pushed back on.
>
> so this is the statement, I sent Dave to explain why that change was in
> there:
>
> ---
> For the btusb driver this adds the promised SCO support. The btusb
> driver is a new driver and will eventually replace hci_usb. Adding SCO
> support was the last missing piece. All distributions are using the
> hci_usb driver at the moment and you can only select one of them. So
> this can't introduce any regression. With this change the distributions
> are now able to select the new driver if they really want to.
> ---
>
> Was this absolutely needed after -rc3. Of course not. No questions asked
> about it. So why did it ended up in there?
>
> Almost everybody is using the hci_usb driver and that one has issues
> that are beyond fixable. So the btusb is its replacement and with this
> change it became a real alternate solution. For me this is a new driver
> that would allow people to use it in case hci_usb gives them a hard time
> and falls over again. And fixing hci_usb is not an option. A lot of
> people tried it and they failed. I think the last one was Pavel a month
> ago. This is why I re-wrote the whole beast from scratch.
>
> So that is my excuse why I thought this would be good choice to push it
> to Dave. No more excuses and no new drivers after the merge window. At
> least not from me.

one of thr goals of the new release approach was to make releases 
frequently enough that it's not a big deal to miss a merge window, you 
only have to wait a couple of months (rather then a couple of years under 
the old model).

while I don't see a bit problem with drivers going in for previously 
unsupported hardware (at least since I custom compile my kernels with all 
unnessasary drivers disabled, so I wouldn't even try to compile them ;-) 
it doesn't hurt much, either as a user, or for you as a developer (as you 
note above) to go ahead and delay till the next merge window.

the benifits of delaying are that the changes in the -rc cycle are clearer 
and smaller. this should make the progress towards the release more 
obvious, and avoid distractions like the one that started this thread. 
yes, this will make the -rc1/-rc2 even bigger as there is more stuff going 
in, but it looks like that is being handled well (in part thanks to the 
preview that -next is providing)

so as a user/tester I want to thank you for being so willing to delay new 
stuff for the next merge window, may others learn to follow your example.

David Lang
