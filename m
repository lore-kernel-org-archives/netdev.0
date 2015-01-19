From: "Harout Hedeshian" <harouth@codeaurora.org>
Subject: RE: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Mon, 19 Jan 2015 09:12:21 -0700
Message-ID: <00c901d03402$b5cb6890$216239b0$@codeaurora.org>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com> <1421679769.32277.15.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "'Hannes Frederic Sowa'" <hannes@redhat.com>,
	"'David Ahern'" <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:57688 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbbASQM0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 11:12:26 -0500
In-Reply-To: <1421679769.32277.15.camel@redhat.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I would still prefer that we flush automatically generated addresses and only
> keep the static and permanent ones.
> 
> What do you think?
> 
> Bye,
> Hannes

If I may offer an opinion, I do feel that there are use cases where flushing the auto-generated addresses in ifdown would not be desirable.

We have one such use case where information regarding the state of the network beyond the interface is managed through sideband signaling. We know that the auto-generated address would still be valid on ifup because the router information is unchanged. In this case, ifup/down is solely being used as a way for user space to enable/disable all traffic on a particular netdevice for temporary periods.

That said, I'm not sure how useful this would be for the average user; I see no harm if it is configurable and the default behavior is unchanged. 

Thanks,
Harout
