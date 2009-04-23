From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: IMQ bug: kernel reboot immediately
Date: Thu, 23 Apr 2009 11:40:19 +0000
Message-ID: <20090423114019.GB6809@ff.dom.local>
References: <20090423084323.GA5696@ff.dom.local> <49F040E8.80402@trash.net> <alpine.LSU.2.00.0904231223050.18687@fbirervta.pbzchgretzou.qr> <49F042E7.7060900@trash.net> <beb91d720904230412j4dea4034o61f2d0682ff76d1a@mail.gmail.com> <49F04F6B.7010709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Salatiel Filho <salatiel.filho@gmail.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	"Y. D." <duyuyang@gmail.com>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:14202 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755831AbZDWLka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 07:40:30 -0400
Content-Disposition: inline
In-Reply-To: <49F04F6B.7010709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 01:22:19PM +0200, Patrick McHardy wrote:
...
> Currently not, the conntrack association is done at a later point.
> We could add a classifier or TC action that performs the lookup
> during ingress classification.

BTW, some time ago I started to wonder how safe are those various
ingress activities wrt. invalid packets, dropped later in ip_rcv().

Jarek P.
