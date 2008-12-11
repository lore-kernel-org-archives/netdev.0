From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH net] Phonet: ensure GPRS device does not go away during TX work
Date: Thu, 11 Dec 2008 10:11:17 +0200
Message-ID: <200812111011.17891.remi.denis-courmont@nokia.com>
References: <200812101514.56827.remi.denis-courmont@nokia.com> <1228914929-26337-1-git-send-email-remi.denis-courmont@nokia.com> <20081210.152845.24693255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "ext David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:53785 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbYLKILc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 03:11:32 -0500
In-Reply-To: <20081210.152845.24693255.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 December 2008 01:28:45 ext David Miller, you wrote:
> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> Date: Wed, 10 Dec 2008 15:15:28 +0200
>
> > We need to hold the device while TX work is pending, as work is flu=
shed
> > only after the network device is unregistered.
> >
> > Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com=
>
>
> This seems unnecessary.
>
> If you simply create proper ->open and ->stop methods for the GPRS ne=
t
> device you can purge the TX queue in ->stop() and avoid this
> refcounting business.

Ok. Can I assume that scheduled work will be flushed sometime between -=
>stop=20
and ->destructor then?

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
