From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Wed, 12 Aug 2009 11:06:14 -0700 (PDT)
Message-ID: <20090812.110614.250284772.davem@davemloft.net>
References: <1248177479-12669-1-git-send-email-remi.denis-courmont@nokia.com>
	<20090721.123449.123442701.davem@davemloft.net>
	<200908121402.25920.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751693AbZHLSGE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:06:04 -0400
In-Reply-To: <200908121402.25920.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Wed, 12 Aug 2009 14:02:25 +0300

> On Tuesday 21 July 2009 22:34:49 ext David Miller wrote:
>> But why don't you create a pn_sock_init() function so you don't
>> have to export so many things from socket.c?
>
> I simply did not think of the sole pn_sock_seq_fops as "so many
> things"... But I can change it if you think it would be better.

Maybe I'm exaggerating, but in any event the less you export from
a file the cleaner it tends to be.
