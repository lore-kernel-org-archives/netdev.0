From: Rick Jones <rick.jones2@hp.com>
Subject: Re: AF_UNIX MSG_PEEK bug?
Date: Tue, 08 Jan 2008 14:40:22 -0800
Message-ID: <4783FBD6.1000004@hp.com>
References: <alpine.BSF.1.00.0801081556580.24286@pkunk.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Brent Casavant <bcasavan@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:47479 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154AbYAHWkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 17:40:24 -0500
In-Reply-To: <alpine.BSF.1.00.0801081556580.24286@pkunk.americas.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Potential bugs notwithstanding, given that this is a STREAM socket, and 
as such shouldn't (I hope, or I'm eating toes for dinner again) have 
side effects like tossing the rest of a datagram, why are you using 
MSG_PEEK?  Why not simply read the N bytes of the message that will have 
the message length with a normal read/recv, and then read that many 
bytes in the next call?

rick jones
