From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: recreate ipv6 link-local addresses when
 increasing MTU over IPV6_MIN_MTU
Date: Mon, 26 Oct 2015 20:05:54 +0100
Message-ID: <1445886354.991864.420737969.5EA6769F@webmail.messagingengine.com>
References: <1445870205-27202-1-git-send-email-hannes@stressinduktion.org>
 <562E4C26.3030501@gmail.com>
 <1445875501.168420.420547673.4BB6C209@webmail.messagingengine.com>
 <562E5DD4.40908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:39080 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753017AbbJZTGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 15:06:15 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id C7681209A5
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 15:05:54 -0400 (EDT)
In-Reply-To: <562E5DD4.40908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

On Mon, Oct 26, 2015, at 18:07, Alexander Duyck wrote:
> Might be a bit longer.  I just realized that I think there is another 
> bug here where you are going through the NETDEV_UP path even though the 
> interface isn't up.  I'll run through some testing this morning to work 
> out the kinks.

When you wrote this, I noticed that if someone removes the LL addresses
to disable the interface and raises the MTU again, we would also start
adding link-local addresses. Probably we need to safe the last state of
disable_ipv6 somewhere in the parent interface. :(

Maybe there is an easier solution for that.

Thanks for your patch, it looks cleaner!

Bye,
Hannes
