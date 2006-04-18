From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TCP]: Fix truesize underflow
Date: Tue, 18 Apr 2006 13:19:48 -0700 (PDT)
Message-ID: <20060418.131948.25497627.davem@davemloft.net>
References: <20060418123204.GA3962@gondor.apana.org.au>
	<200604181829.59686.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, bb@kernelpanic.ru,
	kernel@linuxace.com, nipsy@bitgnome.net,
	jesse.brandeburg@intel.com, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com, ak@suse.de,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2690
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932303AbWDRUUg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 16:20:36 -0400
To: netdev@axxeo.de
In-Reply-To: <200604181829.59686.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Oeser <netdev@axxeo.de>
Date: Tue, 18 Apr 2006 18:29:59 +0200

> But shouldn't we put this kind of hairy manipulation into some nice
> functions?  Driver writers were already confused by all that size,
> len and truesize stuff, as this bug showed.

It's 2 lines and frankly it's a bit context dependant.  I think
Herbert's fix is fine for now.

In the long term, yes, a lot of these weird manipulations need to
be consolidated in well defined functions to make maintainence
and auditing easier.
