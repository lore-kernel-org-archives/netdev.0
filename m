From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [QUESTION] About IPv6 flowlabel in a TCP IPv6 Server
Date: Mon, 22 Jun 2009 11:45:40 +0300
Message-ID: <200906221145.40481.remi.denis-courmont@nokia.com>
References: <4A36F751.6070306@atr.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext Kengo Sakai <kengo.sakai@atr.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:49837 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995AbZFVIoS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 04:44:18 -0400
In-Reply-To: <4A36F751.6070306@atr.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello Kengo-san,

On Tuesday 16 June 2009 04:37:21 ext Kengo Sakai wrote:
> 2) Can a flowlabel be set to a sending packet in a TCP IPv6 Server?

I don't understand your question. To me, you cannot send "packets", at =
least=20
not directly, via TCP sockets in the first place. Userland pushes data =
to the=20
kernel buffers, and those buffers are segmented in some opaque (from us=
erland)=20
way. There is certainly no 1:1 matching of send() calls to packets.

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

