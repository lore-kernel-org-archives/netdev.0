From: David Miller <davem@davemloft.net>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 01:42:12 -0700 (PDT)
Message-ID: <20100415.014212.51881085.davem@davemloft.net>
References: <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	<1265641748.3688.56.camel@bigi>
	<1271245986.3943.55.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, robert@herjulf.net, xiaosuo@gmail.com,
	andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47202
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756053Ab0DOImI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 04:42:08 -0400
In-Reply-To: <1271245986.3943.55.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Wed, 14 Apr 2010 07:53:06 -0400

> I base tested against no rps being used and a kernel which didnt
> have any RPS config on.  [BTW, I had to hand-edit the .config since
> i couldnt do it from menuconfig (Is there any reason for it to be
> so?)]

The RPS config is merely an indirect dependency on SMP as we have it
coded up in the Kconfig files, it's not meant to be user selectable
and is intended to be unconditionally on for SMP builds.
