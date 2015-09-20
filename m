From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/6] switchdev: introduce tranction enfra
 and for pre-commit split
Date: Sun, 20 Sep 2015 10:34:52 +0200
Message-ID: <20150920083452.GB2203@nanopsycho.orion>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bAW6cwRsD2TRMW6K=0dm4Tn+qBb=+-hR2Grb=2RjZRo=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:32881 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530AbbITIez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 04:34:55 -0400
Received: by wiclk2 with SMTP id lk2so109783203wic.0
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 01:34:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bAW6cwRsD2TRMW6K=0dm4Tn+qBb=+-hR2Grb=2RjZRo=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Sep 19, 2015 at 07:46:14PM CEST, sfeldma@gmail.com wrote:
>On Sat, Sep 19, 2015 at 5:29 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Jiri Pirko (6):
>>   switchdev: rename "trans" to "trans_ph".
>>   switchdev: introduce transaction infrastructure for attr_set and
>>     obj_add
>>   rocker: switch to local transaction phase enum
>>   switchdev: move transaction phase enum under transaction structure
>>   rocker: use switchdev transaction queue for allocated memory
>>   switchdev: split commit and prepare phase into two callbacks
>
>Whew, that's a lot of work!  Seems like a good idea to up-level this
>for other drivers to share.  Let me apply the patches and run my tests
>and get back to you.

Expect some blow-ups. Untested. Will test, fix some spelling issues and
post v1, most probably during Monday.

Thanks.
