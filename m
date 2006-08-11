From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [PATCH 3/6] ehea: queue management
Date: Fri, 11 Aug 2006 11:21:32 +0200
Message-ID: <20060811092132.GA4137@wohnheim.fh-wedel.de>
References: <44D99F38.8010306@de.ibm.com> <20060811000540.200CE67B6B@ozlabs.org> <20060811003204.GA6935@martell.zuzino.mipt.ru> <20060811004602.23EB467B64@ozlabs.org> <44DC319A.10802@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Neuling <mikey@neuling.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev@vger.kernel.org, Thomas Klein <tklein@de.ibm.com>,
	linuxppc-dev@ozlabs.org, Christoph Raisch <raisch@de.ibm.com>,
	linux-kernel@vger.kernel.org, Marcus Eder <meder@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wohnheim.fh-wedel.de ([213.39.233.138]:32474 "EHLO
	wohnheim.fh-wedel.de") by vger.kernel.org with ESMTP
	id S1751019AbWHKJVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 05:21:45 -0400
To: Thomas Klein <osstklei@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <44DC319A.10802@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 August 2006 09:28:26 +0200, Thomas Klein wrote:
> Michael Neuling wrote:
> >>>>+static inline u32 map_swqe_size(u8 swqe_enc_size)
> >>>>+static inline u32|map_rwqe_size(u8 rwqe_enc_size)
> > =20
> Agreed. Functions were replaced by a single map_wqe_size() function.

Just a general thing, try to avoid having two identifiers that are
near-100% identical.  As seen in this thread, they are _very_ easy to
confuse.

Ime, there are two methods to avoid this.  One is to make the
identifiers longer, something like "map_seek_wqe_size" and
"map_read_wqe_size".  The other is to make them shorter, just "s" and
"r" is less confusing than the above.

Which method works best depends on many things, including personal
taste.

J=F6rn

--=20
And spam is a useful source of entropy for /dev/random too!
-- Jasmine Strong
