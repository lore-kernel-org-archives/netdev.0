From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable
 when performing the upcall
Date: Fri, 24 May 2013 17:32:43 -0700
Message-ID: <1369441963.3301.459.camel@edumazet-glaptop>
References: <cover.1369406826.git.tgraf@suug.ch>
	 <064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
	 <CAEP_g=87CuiS92YtCZ1V1ME05qq0jGWD9p1WgKZ2jaaG1AWS7w@mail.gmail.com>
	 <1369421900.3301.431.camel@edumazet-glaptop>
	 <CAEP_g=898=iOWV15Y_bcjvS9sGSfDQSP1zQLNkffoXB5imdU7g@mail.gmail.com>
	 <1369432621.3301.445.camel@edumazet-glaptop>
	 <CAEP_g=9Yqcf6_cpPYNAbiQUGjQa46PEz6gQdKAopiNNUDRhGYA@mail.gmail.com>
	 <1369434870.3301.452.camel@edumazet-glaptop>
	 <CAEP_g=_SCmqik=vOQeNF_z7VskG15rovBOLMFx6wPKru0CBDQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:61318 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757Ab3EYAcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 20:32:45 -0400
Received: by mail-ob0-f169.google.com with SMTP id 16so5825266obc.14
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 17:32:45 -0700 (PDT)
In-Reply-To: <CAEP_g=_SCmqik=vOQeNF_z7VskG15rovBOLMFx6wPKru0CBDQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-24 at 17:08 -0700, Jesse Gross wrote:

> What's the alternative?

I guess Thomas was working on this ;)

We addressed all this on nfnetlink lately.

Presumably GSO stuff is a non issue for vSwitch upcalls.

But UDP messages can be big, and their checksum might be already
validated by the NIC.
