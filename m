From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] connect() return value.
Date: Wed, 14 Aug 2002 08:16:44 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208140416.IAA23134@sex.inr.ac.ru>
References: <20020814030242.GA30872@anakin.wychk.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: glee@gnupilgrims.org (Geoffrey Lee)
In-Reply-To: <20020814030242.GA30872@anakin.wychk.org> from "Geoffrey Lee" at Aug 14, 2 01:02:42 pm
List-Id: netdev.vger.kernel.org

Hello!

> to hear your reasons why a read or a write returning -ENOTCONN is a

Because any error but EAGAIN/EINTR is failure. As you convinced
yourself there is no good way to detect connection completion,
so in fact writing correct program is next to impossible.

Actually, never in my life I have seen a pattern of program
with waits for EISCONN after EINTR on connect() (but lots of them
fail when not seeing 0), so I have no idea why they work under these OSes.
Apparently, they fail randomly.

Alexey
