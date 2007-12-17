From: =?iso-8859-1?q?Fl=E1vio_Pires?= <flavio.defreitas@gmail.com>
Subject: Re: Packet per Second
Date: Mon, 17 Dec 2007 11:18:57 +0000 (UTC)
Message-ID: <nemoMon121707091528@flis.man.torun.pl>
References: <nemoFri121407105527@flis.man.torun.pl> <1197671513.5973.10.camel@andromache>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:49787 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935869AbXLQLTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 06:19:13 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1J4E05-0001Co-Ni
	for netdev@vger.kernel.org; Mon, 17 Dec 2007 11:19:09 +0000
Received: from gate2.ip2.com.br ([208.48.246.8])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2007 11:19:09 +0000
Received: from flavio.defreitas by gate2.ip2.com.br with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2007 11:19:09 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <1197671513.5973.10.camel@andromache> Glen
Turner<gdt@gdt.id.au> wrote:
>  On Fri, 2007-12-14 at 15:34 +0000, Fl=87vio Pires wrote:
>>   Well, I work on an ISP and we have a linux box acting as a
>> bridge+firewall. With this bridge+firewall we control the packet
>> rate per second from each client and from our repeaters. But I can`t
>> measure the packet rate per IP. Is there any tool for this?

>  The usual approach is to generate NetFlow records -- there are
>  a number of Linux tools for this. Collect them with a
> collector(flow-tools being a common choice). Then have a Perl script
> which reads the flow records, processes them whichever way you
> desire, and drops the result into a rrdtool file (there are modules
> for both reading the flow-tools data and outputing in the
> rrdtoolformat). The rrdtool utilities have a limited range of graphs,
> but there is a huge selection of graphing packages from other authors
> for rrdtool-stored data (Drraw, etc).  Flow-tools also
>  has some third-party analysis tools, some of those have good
>  "top talker" statistics.

>  This is a lot of work, since you are really putting a
> completemeasurement infrastructure in place to get the one statistic
> you desire.  But I'd encourage you to do that, since knowing
>  one statistic usually leads to further questions of the data

Thx for the answer Glen,

I alread though about something like this. But, isn`t NetFlow just for
Cisco IOS ?



--=20

I'm trying a new usenet client for Mac, Nemo OS X.
You can download it at http://www.malcom-mac.com/nemo


