From: "Nithin Sujir" <nsujir@broadcom.com>
Subject: Re: Problems with tg3 on BCM5720
Date: Thu, 27 Sep 2012 09:38:46 -0700
Message-ID: <50648116.5050506@broadcom.com>
References: <CAKmKYaCBG5hURNomffgp9gRhS7g2BYsNG-LTmBrKsX-iyVzVxg@mail.gmail.com>
 <50636FEA.7080509@broadcom.com>
 <CAKmKYaAWhTwucTP1joMcywv61ugi9gHNDGS3KaJjn6SLhvL5Dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: "Dirkjan Ochtman" <dirkjan@ochtman.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4707 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299Ab2I0QjF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2012 12:39:05 -0400
In-Reply-To: <CAKmKYaAWhTwucTP1joMcywv61ugi9gHNDGS3KaJjn6SLhvL5Dw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 26 September 2012 11:45 PM, Dirkjan Ochtman wrote:
> On Wed, Sep 26, 2012 at 11:13 PM, Nithin Nayak Sujir
> <nsujir@broadcom.com> wrote:
>> 1. Can you tell me the last patch that is included in the tg3 driver in
>> 3.4.9 on your distro?
> There are no tg3-specific patches in my distro's 3.4.9 package.
Ok. I was trying to make my setup here as close to your code to try and 
see the problem. Would you say that the linux-stable tree at 3.4.9 has 
the same tg3 code as your distro?
I'm not able to see a problem with 3.4.9 at gigabit or 100mbit on my 
setup here.
>> 2. Can you give more info about the working setup?
> The working setup is a simple small VLAN with a 192.168.1.0/24 subnet
> and a few other Linux boxes on it (some of them also have BCM5720,
> others have BCM5722 or BCM5709 networking). Not sure what other
> information you'd want about this?
Asking more about the physical setup to see what is different with the 
failing one w.r.t the working case. Is this a gigabit router/switch/hub?

>> 6. I noticed in the syslog, the link is coming up at 100 Mbps. Is this
>> expected?
> No, I don't think so, it should be a Gbit line.
Probably stupid question but have you have tried a different cable?
You mentioned that the switch side works with a laptop? What is the link 
speed on the laptop at that time?


>
>> 7. Does it fail immediately on connect to the data center switch? Or is it
>> after some traffic goes through?
> The vendor whose switch we're connecting to says they see that the
> link is up, but they don't see a MAC attached. One of the things that
> look weird to me is the ifconfig output saying "RX packets:513
> errors:0 dropped:0 overruns:0 frame:0" but also "TX packets:0 errors:0
> dropped:0 overruns:0 carrier:0".
>
> On Wed, Sep 26, 2012 at 11:40 PM, Michael Chan <mchan@broadcom.com> wrote:
>> It is most likely that the device eth0 is down.  The device needs to be
>> up in order to perform all the tests that failed.  Please bring up the
>> device and run the test again.  Thanks.
> Right, sorry about that. Here's the results again, with the interface up:
>
> djc@jansky ~ $ sudo ethtool --test eth0
> The test result is FAIL
> The test extra info:
> nvram test        (online) 	 0
> link test         (online) 	 0
> register test     (offline)	 0
> memory test       (offline)	 0
> mac loopback test (offline)	 0
> phy loopback test (offline)	 5
> ext loopback test (offline)	 0
> interrupt test    (offline)	 0
>
> Hope that helps,
>
> Dirkjan
>
