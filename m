From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware
	dropsrxpackets
Date: Fri, 15 May 2009 15:12:51 -0400
Message-ID: <20090515191251.GF7745@hmsreliant.think-freely.org>
References: <20090514004548.GA14428@localhost.localdomain> <20090514010359.GL6752@linux.vnet.ibm.com> <20090514123300.GA7166@hmsreliant.think-freely.org> <20090514124407.GP3517@psychotron.englab.brq.redhat.com> <20090514172954.GA3867@hmsreliant.think-freely.org> <20090515065102.GB25620@psychotron.englab.brq.redhat.com> <20090515105909.GA7745@hmsreliant.think-freely.org> <20090515112736.GG25620@psychotron.englab.brq.redhat.com> <20090515160702.GE7745@hmsreliant.think-freely.org> <20090515111852.5ec2c371@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33761 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbZEOTNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 15:13:09 -0400
Content-Disposition: inline
In-Reply-To: <20090515111852.5ec2c371@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 11:18:52AM -0700, Stephen Hemminger wrote:
> 
> > +#define is_drop_point_hw(x) do {\
> > +	int ____i, ____j;\
> > +	for (____i = 0; ____i < 8; i ____i++)\
> > +		____j |= x[____i];\
> > +	____j;\
> > +} while (0)
> 
> Would this code be less ugly if it were an inline function?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Possibly, I don't actually use that yet, but was planning on it shortly.  I'll
fiddle with it and update it in a later patch if another format makes mroe sense
 
> 
