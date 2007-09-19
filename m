From: Rick Jones <rick.jones2@hp.com>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 11:38:57 -0700
Message-ID: <46F16CC1.9090302@hp.com>
References: <46F13E8B.4050309@redhat.com> <p73sl5aveqh.fsf@bingen.suse.de>	<46F15305.2030507@redhat.com>	<20070919172653.GB18045@one.firstfloor.org>	<46F1608E.7060908@redhat.com>	<20070919175700.GC18045@one.firstfloor.org>	<46F16418.3070706@redhat.com> <20070919183004.GA18707@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762677AbXISSjd@vger.kernel.org>
In-Reply-To: <20070919183004.GA18707@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Wed, Sep 19, 2007 at 11:02:00AM -0700, Ulrich Drepper wrote:
> 
>>>on UDP/RAW and it's certainly possible to connect() to that. 
>>
>>Where do you get this from?  And where is this implemented?  I don't
> 
> 
> Sorry it's actually loopback, not broadcast as implemented in Linux.
> In Linux it's implemented in ip_route_output_slow(). Essentially
> converted to 127.0.0.1
> 
> I think it's traditional BSD behaviour but couldn't find it on
> a quick look in FreeBSD source (but haven't looked very intensively) 

One has to set their way-back machine pretty far back to find the *BSD 
bits which used 0.0.0.0 as the "all nets, all subnets" (to mis-use a 
term) broadcast IPv4 address when sending.  Perhaps as far back as the 
time before HP-UX 7 or SunOS4.  The bit errors in my dimm memory get 
pretty dense that far back...

It has hung-on in various places (stacks) as an "accepted" broadcast IP 
in the receive path, but not the send path for quite possibly decades now.

rick jones
