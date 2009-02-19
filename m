From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Why linux keeps connected routes when link goes down
Date: Wed, 18 Feb 2009 16:04:36 -0800
Message-ID: <20090218160436.44f19ea0@extreme>
References: <200902190203.41497.homecreate@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?0KXQsNC90LrQuNC9INCa0L7QvdGB0YLQsNC90YLQuNC9?=
	<homecreate@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55263 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180AbZBSAEj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 19:04:39 -0500
In-Reply-To: <200902190203.41497.homecreate@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Feb 2009 02:03:40 +0500
=D0=A5=D0=B0=D0=BD=D0=BA=D0=B8=D0=BD =D0=9A=D0=BE=D0=BD=D1=81=D1=82=D0=B0=
=D0=BD=D1=82=D0=B8=D0=BD  <homecreate@list.ru> wrote:

> Hello!
> Why kernel keeps connected routes when link is not in RUNNING state? =
It's not=20
> only linux behavior, some other OSes do so, but why?
> It's interesting for me because I have a problem with setting up Quag=
ga for=20
> OSPF support. When link goes down (!IFF_RUNNING), Quagga updates only=
 its own=20
> routing table. I must use ifplugd to update routes in kernel (actuall=
y to=20
> delete connected route), but I think it is not a right way.
> So the main question is: why linux keeps connected routes when link g=
oes down?
> PS: ``ip monitor'' reports about link fail after a minute or longer (=
on=20
> 8139too and 3c905x). On some Acorp cards it doesn't notice link failu=
re. Is it=20
> a bad driver or crappy cards? On r8169 I have no problems

There are patches in Vyatta version of Quagga to what you want.
They have been submitted to quagga-developers but the community
process on quagga is much slower than the kernel.
