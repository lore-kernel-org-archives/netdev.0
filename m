From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH net-next 0/8] Add complementary BPF conditional jump instructions
Date: Wed, 2 Jan 2013 11:47:15 +0100
Message-ID: <CAD6jFUTRBcQrodQ7xydMgNyyeHz9bggvJ+tDhApfbGOfznwQMw@mail.gmail.com>
References: <cover.1356960070.git.dborkman@redhat.com>
	<20121231.143715.1238174487756359071.davem@davemloft.net>
	<1357010942.21409.8948.camel@edumazet-glaptop>
	<20121231.211800.1021263690220417469.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59046 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111Ab3ABKrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 05:47:23 -0500
Received: from [78.46.5.203] (helo=sslproxy01.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TqLqz-0008Vm-Ll
	for netdev@vger.kernel.org; Wed, 02 Jan 2013 11:47:21 +0100
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy01.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TqLqz-0000gY-4a
	for netdev@vger.kernel.org; Wed, 02 Jan 2013 11:47:21 +0100
Received: by mail-ee0-f46.google.com with SMTP id e53so6962207eek.33
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2013 02:47:15 -0800 (PST)
In-Reply-To: <20121231.211800.1021263690220417469.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 1, 2013 at 6:18 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 31 Dec 2012 19:29:02 -0800
>
>> On Mon, 2012-12-31 at 14:37 -0800, David Miller wrote:
>>
>>> Whilst I agree that adding NE jumps adds great value and closes a
>>> serious gap, the rest can be synthesized by simply swapping the
>>> arguments and using a comparison that does already exist.
>>>
>>> Why isn't that sufficient?
>>
>> I am afraid none of these patches is needed at all.
>>
>> Swapping the jt/jf is plainly enough for the user land compiler.
>>
>> libcap seems to do it already
>
> Agreed.

Fair enough, it's probably better to let this be done by user space
via such a hack than adding the actual operations for this.
