From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Mon, 23 Mar 2009 18:26:40 -0700
Message-ID: <49C836D0.1080304@hp.com>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk>	<1237503884.16140.23.camel@HP1>	<20090319232541.GA19262@wavehammer.waldi.eu.org>	<20090320.155030.164080684.davem@davemloft.net>	<1237844879.18617.20.camel@HP1>	<20090323222915.GA29609@wavehammer.waldi.eu.org>	<1237850656.18617.34.camel@HP1> <49C825EC.50100@hp.com> <1237857085.18617.47.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bastian Blank <waldi@debian.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:43515 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbZCXB0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 21:26:45 -0400
In-Reply-To: <1237857085.18617.47.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan wrote:
> On Mon, 2009-03-23 at 17:14 -0700, Rick Jones wrote:
> 
>>Michael Chan wrote:
>>
>>>May be I'll break up each firmware section into a
>>>different file and the file name will be updated with each version.
>>>This will allow different sections to be updated separately and older
>>>kernels will still have access to the older firmware.
>>
>>Is that really necessary?  It is enough "fun" finding just the one firmware file 
>>as it is.
> 
> 
> If all the firmware sections are in the same file, much of the firmware
> file will be duplicated in a new file when we update just one section.

So?  Perhaps I'm just experiencing distro pain which may not continue to exist or 
which may not matter to netdev, but when one is installing to a system that uses 
a core NIC which has firmware cast-out into "non-free" siberia, life is "fun" 
enough making sure one has the one firmware file let alone N of them.  If I now 
have to make sure I have all N firmware files, and they are to be updated 
separately, either that means I have to find N packages, or the distros are going 
to package them into one "uber" package that might as well be a single firmware 
file anyway.

rick jones

