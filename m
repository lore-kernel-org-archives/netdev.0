From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net-next: NULL pointer dereference on adding a net namespace
 and a system freeze
Date: Mon, 10 Mar 2014 07:04:36 -0700
Message-ID: <1394460276.3607.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310014452.144b0491@north>
	 <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140310131909.33a3042c@north>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Fan Du <fan.du@windriver.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Jakub =?UTF-8?Q?Kici=C5=84ski?= <moorray3@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:60724 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753409AbaCJOEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 10:04:39 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so7110361pdj.20
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 07:04:38 -0700 (PDT)
In-Reply-To: <20140310131909.33a3042c@north>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 13:19 +0100, Jakub Kici=C5=84ski wrote:

> It helps with the flow_cache warning and BUG ("ip netns add" works) b=
ut
> machine still freezes after 5-10 minutes.  I will try to revert
> ca925cf1534ebcec332c08719a7dee6ee1782ce4 and see if that solves it.

I think the other issue is separate. It might be triggered by
conntracking change.

Thanks !
