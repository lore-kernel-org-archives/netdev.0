From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: bnx2: can't disable rx-vlan-offload?
Date: Wed, 15 Oct 2014 18:25:46 +0200
Message-ID: <DUB123-W27317C3CE8332BB9DE0F59EDAA0@phx.gbl>
References: <DUB123-W35654C3B747AEBC067DAF8EDAD0@phx.gbl>,<543E86A5.8010406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	"Dept-HSGLinuxNICDev@qlogic.com" <dept-hsglinuxnicdev@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub004-omc3s1.hotmail.com ([157.55.2.10]:60987 "EHLO
	DUB004-OMC3S1.hotmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbaJOQZs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 12:25:48 -0400
In-Reply-To: <543E86A5.8010406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,


>> Any ideas or workarounds that may help disabling rx vlan acceleratio=
n?
>
> Try bringing the interface down first. BNX2 is a bit strange in how i=
t handles
> vlan feature changes.

I tried, doesn't work.


Anyway, I reproduced the original issue on e1000e with and without
rxvlan=A0offload, so even if I would be able to disable this on bnx2, t=
he
original problem would not go away.

I will do some more=A0troubleshooting on the original issue with e1000e
and will come back=A0in a new thread if it turns out to be a problem.



Thanks,

Lukas

 		 	   		  