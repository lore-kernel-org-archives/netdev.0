From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ieee802154: fix variable declaration and
 initializer
Date: Tue, 18 Mar 2014 22:13:06 -0700
Message-ID: <1395205986.9114.57.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395199198-14310-1-git-send-email-sakiwit@gmail.com>
	 <1395199941.9114.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1395200557.8649.20.camel@joe-AO722>
	 <1395203754.9114.54.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140319045634.GB1448@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:34785 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbaCSFNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 01:13:07 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so8331830pbb.36
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 22:13:07 -0700 (PDT)
In-Reply-To: <20140319045634.GB1448@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-18 at 22:56 -0600, Jean Sacren wrote:
> Stating it is a "fix" is not a false statement at all. !! falsely
> changes the value to be int TWICE for nothing! Are you still not
> convinced?

I think you are mistaken.

X = !!(a) makes sure X is 0 or 1.

Its a valid and useful construct.

There is no _bug_ here.
