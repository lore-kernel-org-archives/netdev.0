From: Matteo Croce <mcroce@redhat.com>
Subject: Re: [PATCH] netns: more input validation
Date: Tue, 25 Jul 2017 16:08:54 +0200
Message-ID: <1500991734.2615.1.camel@redhat.com>
References: <20170725133031.7735-1-mcroce@redhat.com>
         <063D6719AE5E284EB5DD2968C1650D6DD003FE88@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37108 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750948AbdGYOI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 10:08:57 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD003FE88@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il giorno mar, 25/07/2017 alle 13.47 +0000, David Laight ha scritto:
> Think I'd check:
> 	!name[0] || !memchr(name, 0, NAME_MAX) || strchr(name, '/') ||
> 		(name[0] == '.' && (!name[1] || (name[1] == '.' &&
> !name[2])))
> 
> 	David

Nice optimization, but as strchr() and strcmp() are builtin functions,
at least in GCC, I don't know if there is any real advantage.
