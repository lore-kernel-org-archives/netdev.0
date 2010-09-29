From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [ABI REVIEW][PATCH 0/8] Namespace file descriptors
Date: Wed, 29 Sep 2010 06:09:33 +0300
Message-ID: <201009290609.33773.remi@remlab.net>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:49473 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751462Ab0I2DJ4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 23:09:56 -0400
In-Reply-To: <m1ocborgq7.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Trimming To/Cc heavily)

   Hello,

On Thursday 23 September 2010, Eric W. Biederman wrote:
> Introduce file for manipulating namespaces and related syscalls.
> files:
> /proc/self/ns/<nstype>
>=20
> syscalls:
> int setns(unsigned long nstype, int fd);
> socketat(int nsfd, int family, int type, int protocol);
>=20
> Netlink attribute:
> IFLA_NS_FD int fd.

I have not reviewed the code, but that seems quite nice. At Nokia, we a=
lready=20
use network namespaces to implement the Multimedia Message Service.=20
Inconveniently enough, that is HTTP/TCP/IP in a dedicated IP namespace.=
=20
Similarly, I expect this could be useful to implement the IMS, if/when =
mobile=20
operators start using it (that does not mean Nokia will or will not do =
it).

Using netns, we avoided overlapping with the normal Internet connectivi=
ty.=20
setns() would be much more convenient than fork()+unshare().

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
