From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [TCP]: Fix truesize underflow
Date: Tue, 18 Apr 2006 18:29:59 +0200
Message-ID: <200604181829.59686.netdev@axxeo.de>
References: <20060418123204.GA3962@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Boris B. Zhmurov" <bb@kernelpanic.ru>,
	Phil Oester <kernel@linuxace.com>,
	Mark Nipper <nipsy@bitgnome.net>,
	"David S. Miller" <davem@davemloft.net>,
	jesse.brandeburg@intel.com, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	Andi Kleen <ak@suse.de>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:13511 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1750947AbWDRQaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2006 12:30:46 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060418123204.GA3962@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

Herbert Xu wrote:
> I've copied the code you used in tso_fragment which should work here.

I'm happy to see, that this got resolved and this is a nice minimalistic fix 
for -stable. 

But shouldn't we put this kind of hairy manipulation into some nice functions?
Driver writers were already confused by all that size, len and truesize stuff, 
as this bug showed.


Regards

Ingo Oeser
