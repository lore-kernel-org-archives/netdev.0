From: Andi Kleen <andi@firstfloor.org>
Subject: Re: TCP always advertises zero window.
Date: Mon, 25 Oct 2010 20:18:14 +0200
Message-ID: <87tyka3zmh.fsf@basil.nowhere.org>
References: <4CBFE924.2060103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:44098 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542Ab0JYSSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 14:18:24 -0400
In-Reply-To: <4CBFE924.2060103@gmail.com> (Li Yu's message of "Thu, 21 Oct
	2010 15:17:56 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Li Yu <raise.sail@gmail.com> writes:
>
> 	According to source code, only MTU probing success and receive some non-zero length of L7 payload could grow tcp_sock->rcv_ssthresh. Because of we turn off MTU probing and TCP only received some zero-window probe from another end, so it seem that we have not any chance to update tcp_sock->rcv_ssthresh at all, so a dead loop come here.

The question is why are you turning off MTU probing?

-Andi
