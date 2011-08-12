From: Antonin Steinhauser <as@strmilov.cz>
Subject: Re: TCP port firewall incl. description and english variable names
Date: Fri, 12 Aug 2011 17:37:32 +0200
Message-ID: <4E4548BC.9010108@strmilov.cz>
References: <1313161843-18226-1-git-send-email-as@strmilov.cz> <1313163276.2354.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vip.anoweb.cz ([89.250.248.143]:59997 "EHLO smtp.anoweb.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912Ab1HLQLG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 12:11:06 -0400
In-Reply-To: <1313163276.2354.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK
Dne 12.8.2011 17:34, Eric Dumazet napsal(a):
> Le vendredi 12 ao=C3=BBt 2011 =C3=A0 17:10 +0200, Tonda a =C3=A9crit =
:
>   =20
>> Module that is used to open, close or filter specified TCP port by
>> sending certain sequence of UDP packets to predefined UDP ports
>> (password-like firewall). One sequence of UDP ports is the opening k=
ey
>> and sending packets successively to them opens the TCP port and the
>> second sequence of UDP ports is the closing key and sending packets
>> successively to them closes the TCP port. If between two UDP packets
>> in the sequence comes more than 16 another UDP packets, the sequence
>> (either opening or closing) is aborted. The configuration and view o=
f
>> affected TCP port, opening and closing key and other firewall
>> parameters is made throw use of sysfs.
>>
>> Signed-off-by: Antoine Steinhauser<as@strmilov.cz>
>>     =20
> Antoine
>
> There is no chance this can be added in official linux kernel, its
> really too ugly, and can be implemented using standard iptables rules=
,
> and userland controller, adding encryption and other high level stuff=
 if
> needed.
>
>
>
>
>   =20

