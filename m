From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Tue, 15 Sep 2009 16:11:22 +0300
Message-ID: <15ddcffd0909150611s2e172f19xa8abe794abf13159@mail.gmail.com>
References: <20090910125929.GA32593@redhat.com>
	 <15ddcffd0909140107m4d94f5abh5405074b654bd15d@mail.gmail.com>
	 <20090914080923.GC14030@redhat.com> <4AADFC0A.30305@voltaire.com>
	 <20090914091151.GE14030@redhat.com> <4AAE1026.4090702@voltaire.com>
	 <20090914101012.GA14176@redhat.com> <4AAE4DFC.9080500@voltaire.com>
	 <20090914154011.GB3556@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <ogerlitz@voltaire.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:64115 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbZIONLU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 09:11:20 -0400
Received: by fxm17 with SMTP id 17so1544756fxm.37
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 06:11:23 -0700 (PDT)
In-Reply-To: <20090914154011.GB3556@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/14/09, Michael S. Tsirkin <mst@redhat.com> wrote:
>> 3. for tun fd
>> VM.TX is translated by vhost to sendmsg which is translated by tun t=
o
>> netif_rx which is then handled by the bridge
>> NIC RX=A0=A0goes to the bridge which xmits the packet a tun interfac=
e, now
>> what makes tun provide this packet to vhost and how it is done?

> Same as above. vhost polls tun and calls recvmsg on the socket

no, correct if I'm wrong, but recvmsg calls tun_do_read and the later
calls tun_put_user to the packet goes to user space and not into the vi=
rtq

Or.
