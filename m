From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCHES] TX batching
Date: Mon, 24 Sep 2007 18:38:25 -0400
Message-ID: <1190673505.4264.11.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	 <20070916.161748.48388692.davem@davemloft.net>
	 <1189988958.4230.55.camel@localhost> <1190569987.4256.52.camel@localhost>
	 <46F6AE18.7080708@garzik.org> <1190574713.5030.4.camel@localhost>
	 <46F6C059.6000600@intel.com> <1190582448.4240.2.camel@localhost>
	 <46F76087.8030109@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	krkumar2@in.ibm.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:24929 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756171AbXIXWie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 18:38:34 -0400
Received: by an-out-0708.google.com with SMTP id d31so252436and
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2007 15:38:34 -0700 (PDT)
In-Reply-To: <46F76087.8030109@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-24-09 at 00:00 -0700, Kok, Auke wrote:

> that's bad to begin with :) - please send those separately so I can fasttrack them
> into e1000e and e1000 where applicable.

Ive been CCing you ;-> Most of the changes are readability and
reusability with the batching.

> But yes, I'm very inclined to merge more features into e1000e than e1000. I intend
> to put multiqueue support into e1000e, as *all* of the hardware that it will
> support has multiple queues. Putting in any other performance feature like tx
> batching would absolutely be interesting.

I looked at the e1000e and it is very close to e1000 so i should be able
to move the changes easily. Most importantly, can i kill LLTX?
For tx batching, we have to wait to see how Dave wants to move forward;
i will have the patches but it is not something you need to push until
we see where that is going.

cheers,
jamal

