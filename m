From: kuznet@ms2.inr.ac.ru
Subject: Re: TCP stops sending ACKs after 32 mesg...
Date: Fri, 30 Aug 2002 17:29:56 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200208301329.RAA29187@sex.inr.ac.ru>
References: <010901c25016$d59d17a0$2304a8c0@Ionizer>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sbansal@aplion.stpn.soft.NET (Saurabh Bansal)
In-Reply-To: <010901c25016$d59d17a0$2304a8c0@Ionizer> from "Saurabh Bansal" at Aug 30, 2 05:15:02 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Can anyone tell me if there is any bug/limitation with the Linux-kernel 2.2.xx in comparison to kernel 2.4.xx in the above problem-context??

Yes, it is well known problem of 2.2.

You forget to read at receiver side, do not you? Well, the only workaround
is not to forget to do this.

Alexey
