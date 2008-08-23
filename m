From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Sun, 24 Aug 2008 01:07:18 +0200
Message-ID: <f4845fc0808231607j3ebc1a9el283da725783aa11a@mail.gmail.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
	 <20080821212948.GB4407@verge.net.au>
	 <20080821220444.GA2758@verge.net.au>
	 <f4845fc0808220256y4649f48djf8498fa8e5499dca@mail.gmail.com>
	 <1219399551.4246.10.camel@ernie.internal.graemef.net>
	 <f4845fc0808220349r6c498eddkae80eb47ed0b5a06@mail.gmail.com>
	 <alpine.LNX.1.10.0808221316530.10895@titan.stealer.net>
	 <f4845fc0808220514y64a2db11s459f4662703e6b0e@mail.gmail.com>
	 <1219483206.10379.5.camel@ernie.internal.graemef.net>
	 <Pine.LNX.4.64.0808230818480.21220@wm7d.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Graeme Fowler" <graeme@graemef.net>,
	"Sven Wegener" <sven.wegener@stealer.net>,
	"Simon Horman" <horms@verge.net.au>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com
To: "Joseph Mack NA3T" <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:8020 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850AbYHWXH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 19:07:27 -0400
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out3.google.com with ESMTP id m7NN7KPY016215
	for <netdev@vger.kernel.org>; Sun, 24 Aug 2008 00:07:20 +0100
Received: from nf-out-0910.google.com (nfcd3.prod.google.com [10.48.105.3])
	by spaceape12.eur.corp.google.com with ESMTP id m7NN7JqA025347
	for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 16:07:19 -0700
Received: by nf-out-0910.google.com with SMTP id d3so576920nfc.25
        for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 16:07:19 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0808230818480.21220@wm7d.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 23, 2008 at 5:22 PM, Joseph Mack NA3T <jmack@wm7d.net> wrote:
> On Sat, 23 Aug 2008, Graeme Fowler wrote:
>
>> This also gives us a development timeline that we can offer to
>> interested parties, along the lines of:
>
> we aren't a commercial shop. This is all being done by volunteers. In which
> case features arrive in the time and order that the coder(s) do it.
>
> I don't think we should promise anything.

Right, we can only do our best, and even then we can't make
guarantuees about mainline inclusion...

>> 2008-10 Minimal IPv6 functionality

This is what we have as an experimental version right now. Meaning,
'works for us without problems, but not well tested or reviewed - any
help welcome'.

>> 2008-?? Full IPv6 functionality matching IPv4 features, no IPv6 sync

For fragmentation and other extension headers support, we would
probably need people with more knowledge of the rest of the IPv6 stack
to contribute. However, both features aren't common (especially
fragmentation with IPv6) in this situation, so missing them is not
likely to hurt a lot of people.

The other missing features are the 4 missing schedulers (DH, SH, LBLC,
LBLCR) and the FTP application helper.

>> 2009-?? Restructured sync daemon with full IPv4 and IPv6 support

This seems pretty doable once a protocol is decided upon and should be
done before the previous step, IMO.

Julius

-- 
Julius Volz
Corporate Operations - SysOps

Google Switzerland GmbH

Identification No.:
CH-020.4.028.116-1
