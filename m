From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC, iproute2] tc/mirred: Extend the mirred/redirect
 action to accept additional traffic class parameter
Date: Tue, 1 Aug 2017 15:12:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00483C5@AcuExch.aculab.com>
References: <150154805003.4819.12498976860683140342.stgit@anamdev.jf.intel.com>
 <20170731205133.5e58e47c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
        "kiran.patil@intel.com" <kiran.patil@intel.com>,
        "sridhar.samudrala@intel.com" <sridhar.samudrala@intel.com>,
        "mitch.a.williams@intel.com" <mitch.a.williams@intel.com>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
        "neerav.parikh@intel.com" <neerav.parikh@intel.com>,
        "carolyn.wyborny@intel.com" <carolyn.wyborny@intel.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
To: 'Stephen Hemminger' <stephen@networkplumber.org>,
        Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.184]:53354 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751295AbdHAPMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 11:12:18 -0400
In-Reply-To: <20170731205133.5e58e47c@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger
> Sent: 01 August 2017 04:52
> On Mon, 31 Jul 2017 17:40:50 -0700
> Amritha Nambiar <amritha.nambiar@intel.com> wrote:
> The concept is fine, bu t the code looks different than the rest which
> is never a good sign.
> 
> 
> > +				if ((argc > 0) && (matches(*argv, "tc") == 0)) {
> 
> Extra () are unnecessary in compound conditional.
> 
> > +					tc = atoi(*argv);
> 
> Prefer using strtoul since it has better error handling than atoi()
> 
> > +					argc--;
> > +					argv++;
> > +				}
> 
> 
> Use NEXT_ARG() construct like rest of the code.

Why bother faffing about with argc at all?
The argument list terminates when *argv == NULL.

	David
