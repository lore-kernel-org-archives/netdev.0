From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: recreate ipv6 link-local addresses when
 increasing MTU over IPV6_MIN_MTU
Date: Mon, 26 Oct 2015 17:33:56 +0100
Message-ID: <1445877236.175039.420582401.131556D5@webmail.messagingengine.com>
References: <1445870205-27202-1-git-send-email-hannes@stressinduktion.org>
 <562E4C26.3030501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:55765 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751429AbbJZQd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 12:33:57 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id F38D320480
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 12:33:56 -0400 (EDT)
In-Reply-To: <562E4C26.3030501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Alex,

On Mon, Oct 26, 2015, at 16:52, Alexander Duyck wrote:
> Seems like this code isn't quite correct.  You are calling ipv6_add_dev 
> for slave devices, and if I understand things correctly I don't believe 
> that was happening before and may be an unintended side effect.

Ah, btw., autoconf and ipv6 operation on IFF_SLAVE devices is actually
desired nowadays and don't think we can change this. See also:
<https://patchwork.ozlabs.org/patch/531196/>

Bye,
Hannes
