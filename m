From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] new net device feature: shared-ipv6-cards
Date: Mon, 19 Aug 2002 01:11:31 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020819.011131.82964805.davem@redhat.com>
References: <OFA9FA0A49.89F0FA84-ONC1256C16.004D221E@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru, ak@suse.de
Return-path: <owner-netdev@oss.sgi.com>
To: AHERRMAN@de.ibm.com
In-Reply-To: <OFA9FA0A49.89F0FA84-ONC1256C16.004D221E@de.ibm.com>
List-Id: netdev.vger.kernel.org

   From: "Andreas Herrmann" <AHERRMAN@de.ibm.com>
   Date: Mon, 19 Aug 2002 10:20:19 +0200

   The following changes are performed:
   
    o Documentation/Configure.help
      net/Config.in
           Configure option and help text for the new feature.

No config option please.  If device driver indicates it wants this
behavior with a flag bit, no need to duplicate this logic.
It is likely that it will not be just z-series machines that
will find this useful.
