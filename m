From: "Jorge Bastos" <mysql.jorge@decimal.pt>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
     2.6.28
Date: Fri, 9 Jan 2009 09:42:20 -0000 (WET)
Message-ID: <1071.192.168.1.3.1231494140.squirrel@webmail.decimal.pt>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
    <20090108094231.GD4496@ff.dom.local>
    <20090108095403.GE4496@ff.dom.local>
    <20090108100614.GA5418@ff.dom.local>
    <2025.192.168.1.3.1231410939.squirrel@webmail.decimal.pt>
    <20090108110430.GB5493@ff.dom.local>
    <2111.192.168.1.3.1231413721.squirrel@webmail.decimal.pt>
    <20090108135927.GC5493@ff.dom.local>
    <2321.192.168.1.3.1231423743.squirrel@webmail.decimal.pt>
    <3226.192.168.1.3.1231435651.squirrel@webmail.decimal.pt>
    <20090109075450.GC4605@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Denys Fedoryschenko" <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly08.isp.novis.pt ([195.23.133.218]:51668 "EHLO
	mailrly08.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754086AbZAIJlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 04:41:51 -0500
In-Reply-To: <20090109075450.GC4605@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, Debian using SID.
iproute (that's the last for SID):
ii  iproute                         20080725-2                 networking
and traffic control tools

lira:~# uname -a
Linux lira 2.6.28 #1 SMP Thu Dec 25 12:31:23 WET 2008 i686 GNU/Linux

maybe i should ask the iproute package mainteiner to update it no?



> On Thu, Jan 08, 2009 at 05:27:31PM -0000, mysql.jorge@decimal.pt wrote:
> ....
>> > lira:~# tc -s qdisc show dev eth0
>> > qdisc cbq 1: root rate 12500000bps (bounded,isolated) prio no-transmit
>> >  Sent 5336353 bytes 5737 pkts (dropped 16, overlimits 1382)
> -------------------------------------------------------------> ^^^^^^^^^
>
> BTW, I wonder why you get this output (very) old way - without "requeues"
> stats. Could you tell your iproute2 and kernel (or distro) version?
>
> Jarek P.
>


