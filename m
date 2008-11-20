From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] dccp ccid-3: High-res or low-res timers?
Date: Thu, 20 Nov 2008 07:24:08 +0100
Message-ID: <20081120062408.GD6227@gerrit.erg.abdn.ac.uk>
References: <20081106153824.GA9709@ghostprotocols.net> <5bc4c4570811060946j4d5d8d1mf88f8b92c72b59c7@mail.gmail.com> <5bc4c4570811061004nfc2afdcn6035d49ae654aef1@mail.gmail.com> <5bc4c4570811061017j3acef860vee84992e7295d06d@mail.gmail.com> <5bc4c4570811061405qe72e43cx861c537885804132@mail.gmail.com> <20081108085035.GA7112@gerrit.erg.abdn.ac.uk> <20081115105042.GA7798@gerrit.erg.abdn.ac.uk> <5640c7e00811160014p17414c54v2499c5b1e996278f@mail.gmail.com> <20081118061414.GA4015@gerrit.erg.abdn.ac.uk> <5640c7e00811180941l671fd3a0w390529df9222163e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Leandro Sales <leandroal@gmail.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	DCCP Mailing List <dccp@vger.kernel.org>,
	netdev@vger.kernel.org, DCCP mailing list <dccp@ietf.org>
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:41301 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753206AbYKTGZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 01:25:45 -0500
Content-Disposition: inline
In-Reply-To: <5640c7e00811180941l671fd3a0w390529df9222163e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Ian for the comments and suggestions, which is input for further
work. Hope to start this poco a poco soon.

| > Do you think we could live with clamping the RTT to some sensible
| > minimum, since on a local LAN the use of congestion control is
| > questionable? I was thinking in the order of 0.5 ... 1msec.
| >
| I think that is a good idea - if 1 msec, and HZ = 1000 then we
| wouldn't lose any transmission capability.
| 
Probably it will require a bit of testing, it might be that some
fine-tuning is needed since a lower RTT also means a lower maximum
throughput -- but maybe that limit is fully sufficient for the target
operational range of CCID-3 (streaming, not bulk data transfer).

Gerrit
