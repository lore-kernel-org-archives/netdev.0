From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: HTB - very bad precision? HFSC works fine! 2.6.28
Date: Thu, 8 Jan 2009 00:44:48 +0200
Message-ID: <200901080044.48641.denys@visp.net.lb>
References: <200901080002.37223.denys@visp.net.lb> <200901080036.39519.denys@visp.net.lb> <00a101c97118$e25a6ae0$a70f40a0$@jorge@decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jorge Bastos" <mysql.jorge@decimal.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:45520 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770AbZAGWom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 17:44:42 -0500
In-Reply-To: <00a101c97118$e25a6ae0$a70f40a0$@jorge@decimal.pt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No, it is completely different disciplines

Here is my rules
http://www.nuclearcat.com/badhtb.txt


On Thursday 08 January 2009 00:40:03 Jorge Bastos wrote:
> Sorry my ignorance, HFSC = CBQ ?
> If not, on CBQ it's not working when I apply the rules that I have in the
> bug report.
> One interesting thing, this when I'm using the 1000Mbit card, if I remove
> the TBF line, it works +/- good on the 1000Mbit card.
>
> ---
> /sbin/tc qdisc add dev eth0 parent 1:1280 handle 1280 tbf rate 200Kbit
> buffer 10Kb/8 limit 15Kb mtu 1500
> ---
>
> > -----Original Message-----
> > From: Denys Fedoryschenko [mailto:denys@visp.net.lb]
> > Sent: quarta-feira, 7 de Janeiro de 2009 22:37
> > To: Jorge Bastos
> > Cc: netdev@vger.kernel.org
> > Subject: Re: HTB - very bad precision? HFSC works fine! 2.6.28
> >
> > Well, but byte couting on HFSC works fine.
> >
> > On Thursday 08 January 2009 00:12:30 Jorge Bastos wrote:
> > > I have a similar problem with CBQ that I've been reporting, that may
> >
> > be
> >
> > > related to byte counting also.
> > > It just happens when I use a 1000Mbit NIC.
> > > I've reported it to netfilter@ and created a but report here.
> > > When I insert the old 100Mbit card, it works OK.
> > >
> > > http://bugzilla.kernel.org/show_bug.cgi?id=12364


