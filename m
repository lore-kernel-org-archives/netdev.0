From: kuznet@ms2.inr.ac.ru
Subject: Re: netlink sockets and rtm_newlink messages
Date: Fri, 27 Sep 2002 19:55:02 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209271555.TAA21348@sex.inr.ac.ru>
References: <20020927134806.GA12745@ducksong.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mcmanus@ducksong.COM (Patrick R. McManus)
In-Reply-To: <20020927134806.GA12745@ducksong.com> from "Patrick R. McManus" at Sep 27, 2 06:15:01 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> the messages weren't identical

One of them is a mud. Apparently, I forgot to delete the line
rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING)
in rtnetlink_event().

Alexey
