From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Wed, 10 Jun 2009 07:58:13 -0400
Message-ID: <1244635093.4186.12.camel@dogo.mojatatu.com>
References: <20090603112746.GA7000@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:43675 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275AbZFJL7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 07:59:25 -0400
Received: by qw-out-2122.google.com with SMTP id 5so460625qwd.37
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 04:59:27 -0700 (PDT)
In-Reply-To: <20090603112746.GA7000@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apologies for the latency.

On Wed, 2009-06-03 at 11:27 +0000, Jarek Poplawski wrote:

> After the second look I have some questions:
> - if it's really aimed to skip checking by ->get() tp's before they're
> configured in ->change(), maybe instead of using tp_c to check this it
> would be simpler to generally skip calling ->get() for newly created
> tp's?
> - otherwise the current method probably needs adding a tp_c check for
> NULL in u32_destroy()?
> - it seems this method would also need adding a 'handle' lookup to
> the u32_change(); otherwise its 'handle' parameter isn't controlled
> for for uniqueness, unless I miss something?

Lets just ignore the need for these changes since the patch fixes them
for now. I would still like to make the changes i suggested but later
with more thought put into them.

cheers,
jamal

