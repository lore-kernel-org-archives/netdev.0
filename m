From: Thomas Munck Steenholdt <tmus@tmus.dk>
Subject: Re: [PATCH] 2.6.3 pcnet32.c fix link reporting for non-mii devices
Date: Sat, 21 Feb 2004 08:27:37 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40370869.1040304@tmus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> Thomas,
> 
> Thanks for the input.  I am the unofficial maintainer, sort of.  I don't
> have a card without an mii, so I can't test some of the changes.  Do
> you know of a way to determine the link state so I can correctly return
> the state?
> 
> By the way, are you running 2.4 or 2.6?
> 
> 

This patch was made against 2.6.3 but it seems that at least Linus'
kernel tree has been pretty much untouched for at least a little while,
so i think it'll patch very nicely against some of the newer 2.4 kernels.

If you can test my patch on som NICs with mii and it works I guess it's
okay! The only NIC that doesn't have mii that I have personaly
experience with is the virtual device found in VMware. Thats also the
one I used to test the patch and it works fine.

Perhaps check this comment posted to a redhat kernel bug for info:
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=100527#c5

The guy suggests taking a peek at the LED status register to figure out
if there's a link or not. However I have no idea if that will work for
the VMware NIC anyway and that's the reason for doing it the way I did!

Thomas
