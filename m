From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFC PATCH net] vxlan: fix incorrect RCO bit in VXLAN header
Date: Fri, 4 Dec 2015 18:06:10 +0100
Message-ID: <20151204180610.51732e36@griffin>
References: <67179e9385c71f7c377a7df345d445704f49dbbc.1449233631.git.jbenc@redhat.com>
	<CALx6S35_CbKfNpGJM6xsSgdkd25iekMCS3jwyG7_B5bCfeJhQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56679 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756045AbbLDRGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 12:06:13 -0500
In-Reply-To: <CALx6S35_CbKfNpGJM6xsSgdkd25iekMCS3jwyG7_B5bCfeJhQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Dec 2015 08:43:59 -0800, Tom Herbert wrote:
> What a mess VXLAN has become. There are no guidelines or order in
> defining these reserved bits! If anyone is looking to do some work in
> encapsulation please consider bringing up VXLAN-GPE/NSH in the stack,
> hopefully that world will be better....

I'm actually working right now on VXLAN-GPE implementation (and tons of
cleanups in the vxlan code) which is the reason I noticed this bug.

> Acked-by: Tom Herbert <tom@herbertland.com>

Thanks. David, as this was submitted as RFC, should I resubmit?
Provided that you're okay with the patch, of course; it changes the
on-wire format which should not be taken lightly, even though the
current behavior is incorrect.

 Jiri

-- 
Jiri Benc
