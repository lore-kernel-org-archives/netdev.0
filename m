From: mysql.jorge@decimal.pt
Subject: Re: HTB - very bad precision? HFSC works fine! 2.6.28
Date: Wed, 7 Jan 2009 23:42:01 -0000 (WET)
Message-ID: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
References: <200901080002.37223.denys@visp.net.lb>
    <200901080036.39519.denys@visp.net.lb>
    <00a101c97118$e25a6ae0$a70f40a0$@jorge@decimal.pt>
    <200901080044.48641.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: "Denys Fedoryschenko" <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly01.isp.novis.pt ([195.23.133.211]:51461 "EHLO
	mailrly01.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbZAGXsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 18:48:06 -0500
In-Reply-To: <200901080044.48641.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there anyway to debug this?




> No, it is completely different disciplines
>
> Here is my rules
> http://www.nuclearcat.com/badhtb.txt
>
>
> On Thursday 08 January 2009 00:40:03 Jorge Bastos wrote:
>> Sorry my ignorance, HFSC = CBQ ?
>> If not, on CBQ it's not working when I apply the rules that I have in
>> the
>> bug report.
>> One interesting thing, this when I'm using the 1000Mbit card, if I
>> remove
>> the TBF line, it works +/- good on the 1000Mbit card.
>>
>> ---
>> /sbin/tc qdisc add dev eth0 parent 1:1280 handle 1280 tbf rate 200Kbit
>> buffer 10Kb/8 limit 15Kb mtu 1500
>> ---
>>
>> > -----Original Message-----
>> > From: Denys Fedoryschenko [mailto:denys@visp.net.lb]
>> > Sent: quarta-feira, 7 de Janeiro de 2009 22:37
>> > To: Jorge Bastos
>> > Cc: netdev@vger.kernel.org
>> > Subject: Re: HTB - very bad precision? HFSC works fine! 2.6.28
>> >
>> > Well, but byte couting on HFSC works fine.
>> >
>> > On Thursday 08 January 2009 00:12:30 Jorge Bastos wrote:
>> > > I have a similar problem with CBQ that I've been reporting, that may
>> >
>> > be
>> >
>> > > related to byte counting also.
>> > > It just happens when I use a 1000Mbit NIC.
>> > > I've reported it to netfilter@ and created a but report here.
>> > > When I insert the old 100Mbit card, it works OK.
>> > >
>> > > http://bugzilla.kernel.org/show_bug.cgi?id=12364
>
>
>


