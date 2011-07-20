From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Wed, 20 Jul 2011 17:44:48 +0200
Message-ID: <1311176688.2338.49.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1311105738.3113.11.camel@edumazet-laptop>
	 <20110719202922.GA2352@minipsycho>
	 <1311108107.3113.22.camel@edumazet-laptop>
	 <20110720001904.GA1992@neilslaptop.think-freely.org>
	 <1311122593.3113.46.camel@edumazet-laptop>
	 <4E2626E1.6030005@candelatech.com>
	 <20110720020737.GB2692@neilslaptop.think-freely.org>
	 <1311135855.3113.66.camel@edumazet-laptop>
	 <20110720151827.GD12349@hmsreliant.think-freely.org>
	 <1311175817.2338.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110720153958.GE12349@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, robert.olsson@its.uu.se
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39719 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712Ab1GTPo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 11:44:57 -0400
Received: by wwe5 with SMTP id 5so370835wwe.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 08:44:56 -0700 (PDT)
In-Reply-To: <20110720153958.GE12349@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 juillet 2011 =C3=A0 11:39 -0400, Neil Horman a =C3=A9cri=
t :

> Isn't that exactly what this does?  Disallows a user from issuing the=
 cone_skb
> command in a pktgen script if the underlying driver can't support the=
 sharing of
> skbs.

My bad, I misread your patch. Seems fine to me ;)


