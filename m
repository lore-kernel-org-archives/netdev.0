From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: Enable syn cookies by default
Date: Wed, 21 Oct 2009 14:36:09 -0400
Message-ID: <4ADF5499.2080107@gmail.com>
References: <b2cc26e40910100601q7aed04acjcc9973ef06e6458f@mail.gmail.com>	 <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>	 <b2cc26e40910210017v3885b18dre5021c8a920f30d7@mail.gmail.com>	 <4ADEB752.50103@gmail.com>	 <b2cc26e40910210048y43bdb604pcd356376a93c41e@mail.gmail.com>	 <4ADED186.3040300@gmail.com> <b2cc26e40910210310o31ca24dcv50f8bd0c3234b71b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:2256 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753610AbZJUSgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 14:36:10 -0400
Received: by fg-out-1718.google.com with SMTP id d23so2736086fga.1
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 11:36:14 -0700 (PDT)
In-Reply-To: <b2cc26e40910210310o31ca24dcv50f8bd0c3234b71b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olaf van der Spek wrote:
> How and when do they interfere?
> If syn cookies are enabled and the queue isn't full, they're not used
> so they don't interfere.
> If the queue is full, they do interfere, but the alternative would be
> no connection at all.

You just answered your own question, both "how" and "when"....

> So I really don't see the disadvantage of enabling cookies by default.
> 
On systems with long delay paths, it represents turning back the clock
more than a decade or so.  A better solution is usually a firewall/IDS.
The best solution: I'm working on it.

As I'm sure you're aware, Timestamps and Sack options are fairly crucial.


>> As Ubuntu is debian based, perhaps they can back-port the Ubuntu changes?
> 
> Actually changing the value isn't the problem, but the Debian
> maintainer isn't sure it's a good idea (but he doesn't know why).
> 
Well, that depends.  For a client, it's a good idea, as the defense is
mostly local and rare.  For a server run by a small underfunded ISP, it's
still a good idea as a last ditch defense.  But for a full-fledged ISP,
especially running in a satellite environment or with a lot of dial-up
customers, it's terrible!

That's a reason the Ubuntu configuration approach works for me.

A caveat: I've not run debian directly in many, many years (IIRC, since
Red Hat Colgate), and more recently via Unbuntu (since Badger).  I don't
know whether debian has evolved different installation procedures for
different environments.

My comments are based on fairly extensive experience with deployment of
Yellow Dog Linux servers at an ISP (as a co-founder), and Ubuntu clients
for the past 2 (US) election cycles.

