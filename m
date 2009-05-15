From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware
 dropsrxpackets
Date: Fri, 15 May 2009 11:18:52 -0700
Message-ID: <20090515111852.5ec2c371@nehalam>
References: <20090512163044.GD5019@hmsreliant.think-freely.org>
	<20090513182354.GH6752@linux.vnet.ibm.com>
	<20090514004548.GA14428@localhost.localdomain>
	<20090514010359.GL6752@linux.vnet.ibm.com>
	<20090514123300.GA7166@hmsreliant.think-freely.org>
	<20090514124407.GP3517@psychotron.englab.brq.redhat.com>
	<20090514172954.GA3867@hmsreliant.think-freely.org>
	<20090515065102.GB25620@psychotron.englab.brq.redhat.com>
	<20090515105909.GA7745@hmsreliant.think-freely.org>
	<20090515112736.GG25620@psychotron.englab.brq.redhat.com>
	<20090515160702.GE7745@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35322 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751349AbZEOSS5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2009 14:18:57 -0400
In-Reply-To: <20090515160702.GE7745@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +#define is_drop_point_hw(x) do {\
> +	int ____i, ____j;\
> +	for (____i = 0; ____i < 8; i ____i++)\
> +		____j |= x[____i];\
> +	____j;\
> +} while (0)

Would this code be less ugly if it were an inline function?
