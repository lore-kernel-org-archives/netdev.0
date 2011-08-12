From: Patrick McHardy <kaber@trash.net>
Subject: Re: TCP port firewall incl. description and english variable names
Date: Fri, 12 Aug 2011 17:38:18 +0200
Message-ID: <4E4548EA.9020604@trash.net>
References: <1313161843-18226-1-git-send-email-as@strmilov.cz> <1313163276.2354.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tonda <as@strmilov.cz>, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313163276.2354.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12.08.2011 17:34, Eric Dumazet wrote:
> Le vendredi 12 ao=FBt 2011 =E0 17:10 +0200, Tonda a =E9crit :
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
>> Signed-off-by: Antoine Steinhauser <as@strmilov.cz>
>=20
> Antoine
>=20
> There is no chance this can be added in official linux kernel, its
> really too ugly, and can be implemented using standard iptables rules=
,
> and userland controller, adding encryption and other high level stuff=
 if
> needed.

=46ully agreed. There are also standarized protocols for this.
