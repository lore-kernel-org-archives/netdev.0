From: "David S. Miller" <davem@redhat.com>
Subject: Re: automatic keying works! Re: off by one error in 3des cbc keying
Date: Mon, 18 Nov 2002 15:17:03 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021118.151703.22349880.davem@redhat.com>
References: <20021118.122307.31019623.davem@redhat.com>
	<200211182032.XAA22666@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200211182032.XAA22666@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Mon, 18 Nov 2002 23:32:12 +0300 (MSK)

   I repaired af_key to return error when nobody is registered to get acquires.
   (the patch is enclosed. NOT TESTED!) If you can do the same with xfrm_user,
   we can be more clever.

I applied this patch since Bert tested it :-)  I will take care of
xfrm_user's acquire handling right now.
