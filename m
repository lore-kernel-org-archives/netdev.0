From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v4 3/7] switchdev: remove pointers from switchdev objects
Date: Mon, 12 Oct 2015 20:01:49 -0700
Message-ID: <CAE4R7bBevBoQ=U7P98F2NEh97ocLgvZuc4cS0fZ9BYFapVeR3A@mail.gmail.com>
References: <1444672467-20621-1-git-send-email-jiri@resnulli.us>
 <1444672986-20709-1-git-send-email-jiri@resnulli.us> <1444672986-20709-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:36842 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932181AbbJMDCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 23:02:09 -0400
Received: by oihr205 with SMTP id r205so2517302oih.3
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 20:02:08 -0700 (PDT)
In-Reply-To: <1444672986-20709-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2015 at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> When object is used in deferred work, we cannot use pointers in
> switchdev object structures because the memory they point at may be already
> used by someone else. So rather do local copy of the value.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
