From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 29 Dec 2015 18:38:00 +0300
Message-ID: <5682A8D8.5040403@list.ru>
References: <5682665A.7090102@list.ru> <20151229152208.GA22423@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp48.i.mail.ru ([94.100.177.108]:57718 "EHLO smtp48.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753239AbbL2PiH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 10:38:07 -0500
In-Reply-To: <20151229152208.GA22423@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

29.12.2015 18:22, Sowmini Varadhan =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Do you have admin control over the ubuntu router?
> If yes, you might want to check the shared_media [#] setting=20
> on that router for the interfaces with overlapping subnets.
> (it is on by default, I would try turning it off).
Ahha, good catch, thanks!
Done that, then
ip route flush cache
on host, and am waiting for the problem to re-appear.
Hope it won't... but to say for sure I'll need a day or 2,
as it is not very fast to appear.


> AFAICT, the code does the right thing per rfc1812 when setting
> IPSKB_DOREDIRECT if shared_media is turned off.
Likely the router's side is doing the right thing, but of
course there are still many questions about the host's side.
Namely, why the bad entries were allowed, and how to list them?
The problem would not happen if they are rejected based on a
simple netmask check.

Thanks for your help so far! With shared_media hint you've pretty
likely saved me from lots of headache. :)
