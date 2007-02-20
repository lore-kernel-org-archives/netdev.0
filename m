From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Tue, 20 Feb 2007 14:40:40 -0500
Message-ID: <20070220194040.GA18976@kvack.org>
References: <20070219231447.GA4400@outpost.ds9a.nl> <p73d545drx6.fsf@bingen.suse.de> <20070220162714.GA3245@outpost.ds9a.nl> <20070220164124.GA24930@2ka.mipt.ru> <20070220184242.GA30077@filer.fsl.cs.sunysb.edu> <20070220184859.GA1949@2ka.mipt.ru> <20070220193319.GA8800@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: bert hubert <bert.hubert@netherlabs.nl>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Josef Sipek <jsipek@fsl.cs.sunysb.edu>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:48863 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932975AbXBTTkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 14:40:43 -0500
Content-Disposition: inline
In-Reply-To: <20070220193319.GA8800@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 08:33:20PM +0100, bert hubert wrote:
> I'm investigating this further for other system calls. It might be that my
> measurements are off, but it appears even a slight delay between calls
> incurs a large penalty.

Make sure your system is idle.  Userspace bloat means that *lots* of idle 
activity occurs in between timer ticks on recent distributions -- all those 
widgets polling the hardware to see if something changed or needs updating 
do a lot of damage to the caches.  Try comparing a run under init=/bin/bash 
with one while logged in to a desktop environment to see just how painful it 
is.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
