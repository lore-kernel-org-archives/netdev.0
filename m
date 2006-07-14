From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Fri, 14 Jul 2006 16:36:51 -0700 (PDT)
Message-ID: <20060714.163651.108809235.davem@davemloft.net>
References: <20060714185739.780700000@flek.zko.hp.com>
	<20060714185914.416432000@flek.zko.hp.com>
	<Pine.LNX.4.64.0607141933170.18747@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	sds@epoch.ncsc.mil, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32168
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1945917AbWGNXgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 19:36:44 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0607141933170.18747@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Fri, 14 Jul 2006 19:34:20 -0400 (EDT)

> On Fri, 14 Jul 2006, paul.moore@hp.com wrote:
> 
> > +static inline void netlbl_put_hdr(unsigned char *buffer,
> > +				  const u32 msg_type,
> > +				  const u16 msg_len,
> > +				  const u16 msg_flags,
> > +				  const u32 msg_pid,
> > +				  const u32 msg_seq)
> 
> Why are these parameters marked const?  Seems to be common throughout the 
> code.

Yes, it is pointless to mark non-pointers as "const", especially
these day.
