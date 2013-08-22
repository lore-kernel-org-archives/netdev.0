From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] skge: dma_sync the whole receive buffer
Date: Wed, 21 Aug 2013 21:08:11 -0700
Message-ID: <20130821210811.63f05d36@nehalam.linuxnetplumber.net>
References: <20130810150207.37432299@nehalam.linuxnetplumber.net>
	<20130813.150955.1471100759610399160.davem@davemloft.net>
	<20130813180036.3e639789@nehalam.linuxnetplumber.net>
	<520B59D3.4020103@gmail.com>
	<20130814092022.494caf2b@nehalam.linuxnetplumber.net>
	<520BCC72.8040002@gmail.com>
	<20130815084117.2f48fc58@nehalam.linuxnetplumber.net>
	<52116B9C.8050003@gmail.com>
	<5212E249.2050203@gmail.com>
	<5214E4FB.7010208@gmail.com>
	<20130822004023.GA26938@kroah.com>
	<521585C9.3040809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: poma <pomidorabelisima@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:57704 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461Ab3HVEIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 00:08:16 -0400
Received: by mail-pa0-f45.google.com with SMTP id bg4so209678pad.32
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 21:08:16 -0700 (PDT)
In-Reply-To: <521585C9.3040809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Aug 2013 05:30:17 +0200
poma <pomidorabelisima@gmail.com> wrote:

> On 22.08.2013 02:40, Greg KH wrote:
> > On Wed, Aug 21, 2013 at 06:04:11PM +0200, poma wrote:
> >> Signor Greg you are supposed to be very resourceful guy, especially in
> >> matters concerning the hardware, so please if you can set aside your
> >> valuable time and help us finally resolve this issue.
> > 
> > Please take it up with Stephen, it's his driver, not mine.
> > 
> > greg k-h
> > 
> 
> I guess I wrongly assumed that developers help each other when they get
> stuck. Isn't it obvious that Steph and Dave already decided to ship the
> broken module in da birthday kernel. What can I do in the first place,
> as a simple user. That's why I asked you to help.
> However thank you for the answer.
> 
> 
> poma
> 
> 

If you have the patience and time, it would be useful to bisect the problem.
It may not just be in skge.c but a side effect of other config changes.
