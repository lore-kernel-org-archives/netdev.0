From: "Tim Durack" <tdurack@gmail.com>
Subject: Re: r8169 ethernet bonding problems
Date: Wed, 2 May 2007 13:38:20 -0400
Message-ID: <9e246b4d0705021038q458ab32r1c4f7431e7bd0f1@mail.gmail.com>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com>
	 <20070418181333.GA2261@electric-eye.fr.zoreil.com>
	 <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com>
	 <20070427220918.GB24358@electric-eye.fr.zoreil.com>
	 <9e246b4d0705011317t72bc9413u2b002b71ca3865e9@mail.gmail.com>
	 <20070501204721.GB19212@electric-eye.fr.zoreil.com>
	 <9e246b4d0705011359r208ce760yba6edda835ca67a6@mail.gmail.com>
	 <20070501211754.GB17225@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:22696 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1766899AbXEBRiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 13:38:21 -0400
Received: by wx-out-0506.google.com with SMTP id h31so196565wxd
        for <netdev@vger.kernel.org>; Wed, 02 May 2007 10:38:21 -0700 (PDT)
In-Reply-To: <20070501211754.GB17225@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Yup. Works fine. The randomly changing interface order is proving to
> > be a challenge!
>
> udev should be your friend to do a BUS/ID based rename.

True, but so far I have to force link addrs, force promisc mode, and
now add a udev work-around ;-|

Strange thing is, when the interfaces get initialised as eth0/1/2 in
order, they all have the correct macs. When they appear out of order
(eth5/1/2, eth5/6/1 etc), at least one or more of the macs are messed
up.

Once yesterday I saw them initialise in order, with correct macs. Have
not been able to repeat or figure out if there is some way of
triggering this correct behaviour.

Any more driver patches I can beta test?

Tim:>
