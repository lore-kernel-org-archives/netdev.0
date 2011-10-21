From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next V2] net: introduce ethernet teaming device
Date: Fri, 21 Oct 2011 17:31:30 +0200
Message-ID: <1319211090.32161.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
	 <1319208237.32161.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111021150250.GB10076@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39476 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891Ab1JUPbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 11:31:36 -0400
Received: by wyg36 with SMTP id 36so4097851wyg.19
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 08:31:35 -0700 (PDT)
In-Reply-To: <20111021150250.GB10076@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 21 octobre 2011 =C3=A0 17:02 +0200, Jiri Pirko a =C3=A9crit=
 :
> :( What do you suggest? Set these pointers one-by-one?

Yep, this is the right way to have atomicity guarantee.
