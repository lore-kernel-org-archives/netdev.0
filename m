From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Suppress / delay SYN-ACK
Date: Fri, 13 Oct 2006 06:11:16 +0200
Message-ID: <452F11E4.8050508@cosmosbay.com>
References: <000101c6edd5$a880d430$1a04010a@V505CP> <452E69B2.4030306@hp.com>
 <469958e00610121458h45581840ke0367647a735c635@mail.gmail.com>
 <452EC7B9.2030801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Caitlin Bestler <caitlin.bestler@gmail.com>,
	Martin Schiller <mschiller@tdt.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003mt.neufgp.fr ([84.96.92.56]:16515 "EHLO smTp.neuf.fr")
	by vger.kernel.org with ESMTP id S1751615AbWJMELm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 00:11:42 -0400
Received: from [192.168.30.203] ([88.137.140.131]) by sp604003mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J7200MIS3MNKHR0@sp604003mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Fri, 13 Oct 2006 06:11:12 +0200 (CEST)
In-reply-to: <452EC7B9.2030801@hp.com>
To: Rick Jones <rick.jones2@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones a =E9crit :
>> More to the point, on what basis would the application be rejecting =
a
>> connection request based solely on the SYN?
>=20
> True, it isn't like there would suddenly be any call user data as in=20
> XTI/TLI.

DATA payload could be included in the SYN packet. TCP specs allow this =
AFAIK.

About iptables rules added on the fly by an application that want to pr=
otect=20
its listen queue from random sources of 'blacklisted' peers, this has t=
he=20
limitation of granting sufficient rights to the user running the applic=
ation.

Eric

