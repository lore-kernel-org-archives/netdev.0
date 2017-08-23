From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v4] openvswitch: enable NSH support
Date: Wed, 23 Aug 2017 15:27:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD005F638@AcuExch.aculab.com>
References: <20170821061109.GA72656@cran64.bj.intel.com>
 <20170821101925.3f9b36a1@griffin>
 <20170821083900.GA74649@cran64.bj.intel.com>
 <CFF8EF42F1132E4CBE2BF0AB6C21C58D727494F3@ESESSMB107.ericsson.se>
 <20170821113514.6f0ec15e@griffin>
 <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A55C@ESESSMB107.ericsson.se>
 <20170821115106.70fa1e1d@griffin>
 <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A5C7@ESESSMB107.ericsson.se>
 <20170821135019.5c65b888@griffin>
 <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274C9FB@ESESSMB107.ericsson.se>
 <20170822173513.GM6175@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jiri Benc <jbenc@redhat.com>, "Yang, Yi" <yi.y.yang@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>
To: 'Ben Pfaff' <blp@ovn.org>,
        Jan Scheurich <jan.scheurich@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.192]:65371 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754139AbdHWP2K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 11:28:10 -0400
In-Reply-To: <20170822173513.GM6175@ovn.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Pfaff
> Sent: 22 August 2017 18:35
...
> We solved the alignment problem in OVS userspace a different way, by
> defining our versions of the network protocol headers so that they only
> need 16-bit alignment.  In turn, we did that by defining a
> ovs_16aligned_be32 type as a pair of be16s and ovs_16aligned_be64 as
> four be16s, and using helper functions for reads and writes.
...

If you add __attribute__((aligned(2))) to the 32bit and 64bit structure
members then gcc will do the loads and shifts for you.

	David
