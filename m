From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Anycast usage, final diagnosis? (was: IPv6: Fix broken anycast
Date: Thu, 17 Jul 2003 13:41:31 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307171340160.4378-100000@netcore.fi>
References: <200307171030.OAA13906@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Mika Liljeberg <mika.liljeberg@welho.com>, <davem@redhat.com>,
   <jmorris@redhat.com>, <netdev@oss.sgi.com>, <dlstevens@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307171030.OAA13906@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Jul 2003 kuznet@ms2.inr.ac.ru wrote:
> Wait a second. What the hell is this in anycast.c? How is it possible
> to allow to any user to create reserved anycast?
> This makes them completely useless, everyone on LAN can join
> anycast service and blackhole it, which will prevent listening by real servers.
> 
> This cannot be right. I think the logic is illegally stolen
> from multicast interface: only superuser calls can create/delete anycasts.
> Non-superuser can only listen existing one.
> 
> I would block JOIN/LEAVE for non-superuser completely.

No user should be able to join anycast group, IMHO.

(Of course, that hasn't been specifed anywhere, but the implementations 
should do what they think is best -- and I certainly think this is.)

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
