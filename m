From: Rick Jones <rick.jones2@hp.com>
Subject: Re: is it a backwards compatability catch-22?
Date: Tue, 25 Apr 2006 11:34:49 -0700
Message-ID: <444E6BC9.8090801@hp.com>
References: <444D6396.4010004@hp.com>	<20060424165407.202a86f4@dxpl.pdx.osdl.net> <444D6F78.9080309@hp.com> <4807377b0604250909m34f6030ar19735b3343884399@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:37051 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S932285AbWDYSeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 14:34:50 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0604250909m34f6030ar19735b3343884399@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:
> On 4/24/06, Rick Jones <rick.jones2@hp.com> wrote:
> 
>>>The udev stuff runs after the device has already chosen it's default name.
>>>It has to, it's part of the hotplug infrastructure, and we don't want
>>>to depend on usermode to define the name.  Just choose some other
>>>convention "eth_0"  or something like that.
>>
>>Is that because adding another NIC at a later time might cause it to
>>grab ethN out from under what I'm trying to do with udev?
> 
> 
> From what I read its likely to be because there may already be a
> device named "eth1" due to default naming when you are trying to
> rename a device (say eth0) to eth1.
> 
> this is all because Debian now has async init, right?

Beats me. I got the impression that udev things were happening "early 
enough" in my case that I didn't run into the issue.  still, init and 
device names are presently a maze of twisty passages to me. someone else 
also suggested not using the ethN stuff - or at least not starting at 0, 
but start them at N where N is reasonably large.  i decided to call them 
lan0, lan1, etc just to be perverse and see what breaks.

> BTW, since the letters in udev are all hex, it shouldn't matter
> whether they are upper or lower case, IMO

that would be my opinion as well, certainly that was my expectation - 
that I could simply "cut and paste" MAC addresses from the likes of 
ifconfig output

alas, it seems that if I leave theme upper case, the renaming does not 
happen.  i am _guessing_ the comparison is a simple string compare. and 
it doesn't _really_ know that what is being compared is a MAC address?

rick jones
