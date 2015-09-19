From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next RFC 0/6] switchdev: introduce tranction enfra and
 for pre-commit split
Date: Sat, 19 Sep 2015 10:46:14 -0700
Message-ID: <CAE4R7bAW6cwRsD2TRMW6K=0dm4Tn+qBb=+-hR2Grb=2RjZRo=Q@mail.gmail.com>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:32878 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755748AbbISRqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 13:46:35 -0400
Received: by oixx17 with SMTP id x17so41202290oix.0
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 10:46:34 -0700 (PDT)
In-Reply-To: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 19, 2015 at 5:29 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Jiri Pirko (6):
>   switchdev: rename "trans" to "trans_ph".
>   switchdev: introduce transaction infrastructure for attr_set and
>     obj_add
>   rocker: switch to local transaction phase enum
>   switchdev: move transaction phase enum under transaction structure
>   rocker: use switchdev transaction queue for allocated memory
>   switchdev: split commit and prepare phase into two callbacks

Whew, that's a lot of work!  Seems like a good idea to up-level this
for other drivers to share.  Let me apply the patches and run my tests
and get back to you.
