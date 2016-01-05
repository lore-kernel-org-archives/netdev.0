From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH stable-3.2 stable-3.12] net: fix checksum check in
 skb_copy_and_csum_datagram_iovec()
Date: Tue, 5 Jan 2016 17:41:09 +0100
Message-ID: <568BF225.7050907@suse.cz>
References: <20151228140157.6F592A0C7D@unicorn.suse.cz>
 <568BF0FD.4010208@suse.cz> <1452012008.2768.82.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>,
	Michal Kubecek <mkubecek@suse.cz>, stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:33294 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbcAEQlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 11:41:12 -0500
In-Reply-To: <1452012008.2768.82.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

On 01/05/2016, 05:40 PM, Ben Hutchings wrote:
> On Tue, 2016-01-05 at 17:36 +0100, Jiri Slaby wrote:
>> On 12/28/2015, 03:01 PM, Michal Kubecek wrote:
>>> Recent fix "net: add length argument to 
>>> skb_copy_and_csum_datagram_iovec" added to some pre-3.19
>>> stable branches, namely
>>> 
>>> stable-3.2.y: commit 127500d724f8 stable-3.12.y: commit
>>> 3e1ac3aafbd0
>> 
>> Applied this fix to 3.12. Thanks!
> [...]
> 
> You don't want this, you want Eric's fix (commit 197c949e7, "udp: 
> properly support MSG_PEEK with truncated buffers") although that's
> not upstream yet.

Dropped then. Thanks!


- -- 
js
suse labs
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWi/IlAAoJEL0lsQQGtHBJ+HkP/RSxEleW2xhvRXBVz9S5iTgR
U5dDY3gdpajVuouc8S8ZC8o6/BT+rx0LwzrCcb8RDkIOPad3dFVrcPn5uwZvCZ+b
JSNKvNLTLgtn/jvSu5ZhjlL0F4zXu2Pl37KZpaimwEgGAEmfKAvLL52mdHWURGRq
AD7qD5UJxybejt8VNpExX6Oo+Q6nsRJtbrXXSRbalpeCwUhMxu+A/0vWFQ+bFR4M
GPMw6GqhCoCTy1fcpI4csyvEJImg91PAnNc2+37vOUqxrpr4hqBtNnVerampaI1N
u6QGl5WxfqvX+sDeYv7JDCR+2D750EixcfI6PYFdINSgTBn/7veKTsN1buj9JzlU
LBVFKXLILX3pOj16rIiwVtmqapinyJB9c3vCUDP19opn7LtkR16a5wDOTD3T59zs
KX6FZ0mO3uRacJNpVqeAcYQ8MVFIN6JRCCokJoTgFmia19rSpxV3Th1MoFy/bafX
yc5T+n0CYguTVirME2hn2vt2JHvUzUCcabktT0chY8EhXTc6XMBefRGWnhL3raBe
zRCn8tnGUbawr46ZbwMggpavfzUg3lGE6Y5/g5l5dNmdrLfU5SnNmid769Uvlrad
MFf56DMfMFHmojcqOukcN1v97jvmaK9eY2xXRvuoGnzYexL2JCiPEKfB21NQfZhW
NZSya8PXfCtyAnUS+56r
=hGxr
-----END PGP SIGNATURE-----
