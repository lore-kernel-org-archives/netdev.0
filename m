From: David Newall <davidn@davidnewall.com>
Subject: Re: [RFC net-next 0/4] Support UID range routing.
Date: Wed, 30 Apr 2014 17:22:51 +0930
Message-ID: <5360ABD3.2020506@davidnewall.com>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com> <535BB149.3090901@davidnewall.com> <CAKD1Yr0J3JXu9__LH6uKGsPYq+0jxiP1qhS2NTwT9gHitZ16_Q@mail.gmail.com> <CAKD1Yr2J-UgU+Ycu4pf3L51-1tN1fnxQxDo8fLj+9yb4jQuGZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, JP Abgrall <jpa@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:60167 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071AbaD3Hw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 03:52:58 -0400
In-Reply-To: <CAKD1Yr2J-UgU+Ycu4pf3L51-1tN1fnxQxDo8fLj+9yb4jQuGZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/04/14 14:06, Lorenzo Colitti wrote:
> The use of NAT [...] makes it impossible for the app to know its
> real IP address and port

The original address *is* the real address.  NAT breaks IP's design and 
is a very mixed blessing.  NAT isn't needed nor used with IPv6, and 
being in IPv4's twilight years, an argument predicated on NAT is not 
very convincing.

I feel that describing the patch as routing is misleading, as it 
performs only outbound link selection.  It fosters an expectation of 
bi-directionality, and that is not the case.  It will often result in 
asymmetric routes.

Is it possible you are trying to solve a problem which has already been 
solved, for example by IGP?
