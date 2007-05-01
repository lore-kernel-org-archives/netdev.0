From: "Tim Durack" <tdurack@gmail.com>
Subject: Re: r8169 ethernet bonding problems
Date: Tue, 1 May 2007 16:59:28 -0400
Message-ID: <9e246b4d0705011359r208ce760yba6edda835ca67a6@mail.gmail.com>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com>
	 <20070418181333.GA2261@electric-eye.fr.zoreil.com>
	 <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com>
	 <20070427220918.GB24358@electric-eye.fr.zoreil.com>
	 <9e246b4d0705011317t72bc9413u2b002b71ca3865e9@mail.gmail.com>
	 <20070501204721.GB19212@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:13897 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945925AbXEAU73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 16:59:29 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1934926wxd
        for <netdev@vger.kernel.org>; Tue, 01 May 2007 13:59:28 -0700 (PDT)
In-Reply-To: <20070501204721.GB19212@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Can you try to set the MAC address by hand with the completely patched
> kernel (i.e. including the mac-address-change patch) ?

Yup. Works fine. The randomly changing interface order is proving to
be a challenge!

> Given the last report in http://bugzilla.kernel.org/show_bug.cgi?id=6032,
> it should be straightforward with your Debian system.
>
> No clear idea why your three cards are not handled the same though.
