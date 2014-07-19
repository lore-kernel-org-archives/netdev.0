From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH V3] netxen: fix ethtool rx_dropped information in ethtool get_ethtool_stats()
Date: Sat, 19 Jul 2014 13:45:49 +0800
Message-ID: <049BCC6F-0A2E-421A-9873-0B7ED6FFB3AC@gmail.com>
References: <1405655009-18975-1-git-send-email-ethan.zhao@oracle.com> <C562D0E12CBDE44E8A0CCAB77060096701283AD344@AVMB1.qlogic.org>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ethan Zhao <ethan.zhao@oracle.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C562D0E12CBDE44E8A0CCAB77060096701283AD344@AVMB1.qlogic.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



=D4=DA 2014=C4=EA7=D4=C219=C8=D5=A3=AC=C9=CF=CE=E72:21=A3=ACRajesh Boru=
ndia <rajesh.borundia@qlogic.com> =D0=B4=B5=C0=A3=BA

>> -----Original Message-----
>> From: Ethan Zhao [mailto:ethan.zhao@oracle.com]
>> Sent: Friday, July 18, 2014 9:13 AM
>> To: Manish Chopra; Sony Chacko; Rajesh Borundia; netdev
>> Cc: linux-kernel; ethan.kernel@gmail.com; Ethan Zhao
>> Subject: [PATCH V3] netxen: fix ethtool rx_dropped information in et=
htool
>> get_ethtool_stats()
>>=20
>> netxen driver has implemented netxen_nic_get_ethtool_stats() interfa=
ce,
>> but it doesn't collect stats.rxdropped in driver, so we will get dif=
ferent
>> rx_dropped statistic information while using ifconfig and ethtool.
>> this patch fills stats.rxdropped field with data from net core with
>> dev_get_stats() just as ixgbe driver did for some of its stats.
>=20
> I think ethtool stats are adapter specific. Driver does not maintain
> rx_dropped stats and we also don't get it from adapter.  I am not
> sure if ethtool stats should match ifconfig stats as ifconfig also
> adds net core stats to adapter stats.
I held the same point as yours before I read more drivers implementatio=
n under
Ethernet dir, in fact there is no specification/convention that ethtool=
 info is adapter
Specific. All information output by ethtool is based on the information=
 name itself,
One fact we want this patch is netxen defined 'rx dropped' field but ou=
tput nothing.

>=20
> If ethtool stats should report same values as ifconfig stats then
> we may also need to fix tx_dropped statistics.
>=20
at least, tx dropped output information...=20

Thanks,
Ethan
> Thanks,
> Rajesh
