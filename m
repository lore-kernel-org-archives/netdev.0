From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable
 when performing the upcall
Date: Sat, 25 May 2013 07:39:32 -0700
Message-ID: <1369492772.3301.468.camel@edumazet-glaptop>
References: <cover.1369406826.git.tgraf@suug.ch>
	 <064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
	 <CAEP_g=87CuiS92YtCZ1V1ME05qq0jGWD9p1WgKZ2jaaG1AWS7w@mail.gmail.com>
	 <1369421900.3301.431.camel@edumazet-glaptop>
	 <CAEP_g=898=iOWV15Y_bcjvS9sGSfDQSP1zQLNkffoXB5imdU7g@mail.gmail.com>
	 <1369432621.3301.445.camel@edumazet-glaptop>
	 <CAEP_g=9Yqcf6_cpPYNAbiQUGjQa46PEz6gQdKAopiNNUDRhGYA@mail.gmail.com>
	 <20130525070222.GB30252@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:65181 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756485Ab3EYOje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 May 2013 10:39:34 -0400
Received: by mail-pb0-f49.google.com with SMTP id rp8so5212415pbb.8
        for <netdev@vger.kernel.org>; Sat, 25 May 2013 07:39:33 -0700 (PDT)
In-Reply-To: <20130525070222.GB30252@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-05-25 at 08:02 +0100, Thomas Graf wrote:

> I ran TCP_CRR to verify the SYN/ACK use case and I did not
> observe a difference. If you have any specific test in mind
> I will be glad to run that before posting the 2nd revision.

I guess you should test with rx checksum disabled as well, Jesse seemed
to be concerned about that.

ethtool -K eth0 rx off
