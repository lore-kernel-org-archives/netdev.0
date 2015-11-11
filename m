From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Wed, 11 Nov 2015 10:43:44 -0800
Message-ID: <1447267424.17135.115.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443313848-751-1-git-send-email-tolga.ceylan@gmail.com>
	 <877fnc7i0i.fsf@bytheb.org>
	 <CALmu+Sx8L5mWf3Nnbz=x0qt7pC5n5oVPRJd7dnLATVpmmO+nrA@mail.gmail.com>
	 <1443320655.3273.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34PkfKS47_FxuqwDbqP9P0C5J7YRR5e_-BLjfkPwPRgXw@mail.gmail.com>
	 <1447222769.17135.92.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S37FOq+JVs8LKh5ezR9JhATrz2=NhmbEYPUxUt8Cyb9xaw@mail.gmail.com>
	 <1447262610.17135.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S37B4mGqYe63JkLmPeQNuOX_WMK2NHaOe7Dtt79Nv9Mo4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36425 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbbKKSnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 13:43:46 -0500
Received: by pacdm15 with SMTP id dm15so38068172pac.3
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 10:43:45 -0800 (PST)
In-Reply-To: <CALx6S37B4mGqYe63JkLmPeQNuOX_WMK2NHaOe7Dtt79Nv9Mo4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-11 at 10:23 -0800, Tom Herbert wrote:

> How about doing this in shutdown called for a listener?

Seems a good idea, I will try it, thanks !
