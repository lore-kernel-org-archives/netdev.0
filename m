From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable
 when performing the upcall
Date: Fri, 24 May 2013 15:34:30 -0700
Message-ID: <1369434870.3301.452.camel@edumazet-glaptop>
References: <cover.1369406826.git.tgraf@suug.ch>
	 <064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
	 <CAEP_g=87CuiS92YtCZ1V1ME05qq0jGWD9p1WgKZ2jaaG1AWS7w@mail.gmail.com>
	 <1369421900.3301.431.camel@edumazet-glaptop>
	 <CAEP_g=898=iOWV15Y_bcjvS9sGSfDQSP1zQLNkffoXB5imdU7g@mail.gmail.com>
	 <1369432621.3301.445.camel@edumazet-glaptop>
	 <CAEP_g=9Yqcf6_cpPYNAbiQUGjQa46PEz6gQdKAopiNNUDRhGYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:40067 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893Ab3EXWeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 18:34:31 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so4707511pbb.6
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 15:34:31 -0700 (PDT)
In-Reply-To: <CAEP_g=9Yqcf6_cpPYNAbiQUGjQa46PEz6gQdKAopiNNUDRhGYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-24 at 15:18 -0700, Jesse Gross wrote:

> Offloads are supported. What I want to know is how they affect
> performance with this change.

Hmm, I do not understand why you are checksumming then.

skb_copy_and_csum_dev() is a killer.
