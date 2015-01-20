From: Rick Jones <rick.jones2@hp.com>
Subject: Re: BW regression after "tcp: refine TSO autosizing"
Date: Tue, 20 Jan 2015 11:44:08 -0800
Message-ID: <54BEB008.2070402@hp.com>
References: <54B54C72.8060705@dev.mellanox.co.il> <1421175434.4099.21.camel@edumazet-glaptop2.roam.corp.google.com> <CAJ3xEMibMzJH-AB7pBnO9qBL4McTdsajqHzxXkadnTf1khNdxA@mail.gmail.com> <54B590FB.5040805@dev.mellanox.co.il> <1421186430.11734.6.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_57Zgx3DoQbQMffAJNMeZHa8Yb8M+JuwEH=1Fo_Xou+DkgcQ@mail.gmail.com> <1421603317.11734.154.camel@edumazet-glaptop2.roam.corp.google.com> <54BC286B.8000605@mellanox.com> <1421720216.11734.188.camel@edumazet-glaptop2.roam.corp.google.com> <CAA93jw42i37s5BJO5QJvFc=JnQBT5JsOX4QDxT6yKY3Ha3J3rg@mail.gmail.com> <1421723651.17892.3.camel@edumazet-glaptop2.roam.corp.google.com> <54BEA91D.1050001@hp.com> <1421781991.4832.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Taht <dave.taht@gmail.com>, Eyal Perry <eyalpe@mellanox.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Ancel <amira@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2353.austin.hp.com ([15.217.128.52]:54522 "EHLO
	g2t2353.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbbATToL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 14:44:11 -0500
In-Reply-To: <1421781991.4832.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> More stuff to pull from a TCP_INFO call I presume?  Feel free to drop me
>> a patch, though I'd probably want it to be in the guise of the omni
>> output selectors.
>>
>
> It was something like :

I'd forgotten about dump_tcp_info() :)

Committed revision 673.

happy benchmarking,

rick
