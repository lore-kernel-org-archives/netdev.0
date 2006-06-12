From: Mark Lord <lkml@rtr.ca>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Mon, 12 Jun 2006 11:38:56 -0400
Message-ID: <448D8A90.3040508@rtr.ca>
References: <44886381.9050506@goop.org> <200606090546.15923.ak@suse.de> <448992B7.1050906@rtr.ca> <200606121321.30388.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Matt Mackall <mpm@selenic.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752061AbWFLPjA@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200606121321.30388.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Friday 09 June 2006 17:24, Mark Lord wrote:
>> Andi Kleen wrote:
>>> If your laptop has firewire you can also use firescope.
>>> (ftp://ftp.suse.com/pub/people/ak/firescope/) 
>> ..
>>> FW keeps running as long as nobody resets the ieee1394 chip.
>> This looks interesting.  But how does one set it up for use
>> on the *other* end of that firewire cable?  The Quickstart and
>> manpage don't seem to describe this fully.
> 
> It's in the manpage:
> 
>> .SH NOTES
>> The target must have the ohci1394 driver loaded. This implies
>> that firescope cannot be used in early boot.
> 
> That's it.

Okay, so I'm daft.  But.. *what* is "it" ??

We have two machines:  target (being debugged), and host (anything).
Sure, the target has to have ohci1394 loaded, and firescope running.
But what about the *other* end of the connection?  What commands?

Thanks
