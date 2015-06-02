From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next v2] ipv4: inet_bind: check the addr_len first
Date: Tue, 02 Jun 2015 16:33:32 +0200
Message-ID: <1433255612.1164050.284752905.33D64748@webmail.messagingengine.com>
References: <1433247664-7151-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Denis Kirjanov <kda@linux-powerpc.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:33288 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758853AbbFBOdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 10:33:33 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 173C020D1A
	for <netdev@vger.kernel.org>; Tue,  2 Jun 2015 10:33:33 -0400 (EDT)
In-Reply-To: <1433247664-7151-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, Jun 2, 2015, at 14:21, Denis Kirjanov wrote:
> Perform the address length check first, before calling
> the proto specific bind() function

Can you give more detail why you did this change and what bug it fixes?

Thanks,
Hannes
