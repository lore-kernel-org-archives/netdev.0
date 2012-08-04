From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: TCP Delayed ACK in FIN/ACK
Date: Sat, 4 Aug 2012 16:51:24 +0200
Message-ID: <CAFLxGvxqj+-rf5twsMPk-pRQqzqsK8-MSsKaez9cwarPmyEqzw@mail.gmail.com>
References: <CACS4u_zUF9T0rSsndhyVzgaauOBFJ4LTUeb432B1zg_oLHvTsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-2?Q?S=B3awek_Janecki?= <janecki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:53506 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643Ab2HDOvZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 10:51:25 -0400
In-Reply-To: <CACS4u_zUF9T0rSsndhyVzgaauOBFJ4LTUeb432B1zg_oLHvTsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 4, 2012 at 4:45 PM, S=C5=82awek Janecki <janecki@gmail.com>=
 wrote:
> I have a node.js client (10.177.62.7) requesting some data from http
> rest service from server (10.177.0.1).
> Client is simply using nodejs http.request() method (agent=3Dfalse).
> Client is on Ubuntu 11.10 box.
> Why client sends FIN ACK after 475ms? Why so slow? He should send FIN
> ACK immediately.
> I have many situations like this. About 1% of whole traffic is reques=
t
> with delayed FIN ACK.
> Cpu idle on the client is about 99%, so nothing is draining CPU.
> How to debug this? What could it be? Is there any sysctl option I nee=
d to tune?
> I think this behaviour is the Delayed ACK feature of RFC1122 TCP stac=
k.
>
> Link to tcpdump picture (done on a client machine) :
> http://i48.tinypic.com/35cpogx.png
>
> Can you tell why kernel delayed that FIN/ACK.
> In tcpflow data there is exacly one ACK per packet comming from serve=
r.
> Why kernel delayed client FIN/ACK.
> It could avoid sending ACK every 'data' packet.
> But it choose to delay FIN/ACK?
> Is this possible? Is this a bug?
>
> I've also posted question on stackexchange:
> http://stackoverflow.com/questions/11711218/client-sends-delayed-fin-=
ack-500ms-to-server
>
> Please help.

CC'ing netdev.

--=20
Thanks,
//richard
