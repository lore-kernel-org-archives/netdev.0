From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] bluetooth : move children of connection device to NULL
	before connection down
Date: Tue, 22 Jan 2008 12:39:20 +0100
Message-ID: <1201001960.7978.158.camel@aeonflux>
References: <20080121044913.GA4162@darkstar.te-china.tietoenator.com>
	 <20080121045401.GB4162@darkstar.te-china.tietoenator.com>
	 <20080121.031417.171098597.davem@davemloft.net>
	 <1200982696.7978.148.camel@aeonflux>
	 <a8e1da0801220024u30e9c814va74e44252fc8b11e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bluez-devel@lists.sourceforge.net,
	cornelia.huck@de.ibm.com, gombasg@sztaki.hu, htejun@gmail.com,
	viro@zeniv.linux.org.uk, kay.sievers@vrfy.org, greg@kroah.com
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:44341 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbYAVLk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 06:40:29 -0500
In-Reply-To: <a8e1da0801220024u30e9c814va74e44252fc8b11e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> could you tell something more about your coding style?
> I would like to submit patches about bluetooth according to your sytle
> later If I have.
> 
> Maybe you could put it on the bluez web site or anywhere.

it follows closely the kernel coding style as layout within the kernel
documentation. However there are some minor style things, that I am
going to enforce from time to time. Like having the container_of or
get_user_data calls at the top of the variable declaration. This has
never formalized as far as I recall, but makes from my point of view the
code clearer and easier to read.

Some other times I like an extra empty line to more visual separate
different code blocks. For this some people might agree with me others
might disagree. It is fully a personal more liking one way over the
other.

When it comes to indentation and placement of braces etc. I is 100% the
kernel coding style and nothing else. If not, then it needs fixing and
is an oversight from the old days.

Regards

Marcel


