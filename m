From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: [PATCH 2/3] mlsxfrm: Various fixes
Date: Wed, 8 Nov 2006 08:31:00 -0600
Message-ID: <000501c70342$83b9df70$cc0a010a@tcssec.com>
References: <Pine.LNX.4.64.0611071536300.20855@d.namei>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:35634 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1754585AbWKHOb1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 09:31:27 -0500
To: "'James Morris'" <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0611071536300.20855@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Fix SO_PEERSEC for tcp sockets to return the security context of
> > the peer (as represented by the SA from the peer) as opposed to the
> > SA used by the local/source socket.
>
> What about the case of a localhost TCP connection not using
> xfrm labeling?
>
> Joe Nall raised this as an important requirement.

Yes. We need to come up with some new ideas on this (the failed
secid-recon patchset sought to do this using the secmark field
on the skb).

The scope of this patchset is to strictly fix things related to
labeled-xfrm.
>
>
>
> (Also, 'mlsxfrm' is MLS-specific).

Will switch to "labeled-ipsec".

