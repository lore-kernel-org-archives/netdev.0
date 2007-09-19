From: Andi Kleen <andi@firstfloor.org>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 20:30:04 +0200
Message-ID: <20070919183004.GA18707@one.firstfloor.org>
References: <46F13E8B.4050309@redhat.com> <p73sl5aveqh.fsf@bingen.suse.de> <46F15305.2030507@redhat.com> <20070919172653.GB18045@one.firstfloor.org> <46F1608E.7060908@redhat.com> <20070919175700.GC18045@one.firstfloor.org> <46F16418.3070706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:48978 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbXISSaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 14:30:05 -0400
Content-Disposition: inline
In-Reply-To: <46F16418.3070706@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 11:02:00AM -0700, Ulrich Drepper wrote:
> > on UDP/RAW and it's certainly possible to connect() to that. 
> 
> Where do you get this from?  And where is this implemented?  I don't

Sorry it's actually loopback, not broadcast as implemented in Linux.
In Linux it's implemented in ip_route_output_slow(). Essentially
converted to 127.0.0.1

I think it's traditional BSD behaviour but couldn't find it on
a quick look in FreeBSD source (but haven't looked very intensively) 

Admittedly port 0 is somewhat dodgy for UDP too, but at least in RAW
context it might be valid.

-Andi
