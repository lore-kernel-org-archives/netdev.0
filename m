From: =?ISO-8859-1?Q?Fran=E7ois_Valenduc?=
	<francois.valenduc-bmtTS95sd5BUM80lpFwj4w@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 11144] New: dhcp doesn't work with iwl4965
Date: Wed, 23 Jul 2008 09:58:21 +0200
Message-ID: <4886E49D.6010700@tvcablenet.be>
References: <bug-11144-10286@http.bugzilla.kernel.org/> <20080722034850.dbbc5566.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080722034850.dbbc5566.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andrew Morton a =E9crit :
> (switched to email.  Please respond via emailed reply-to-all, not via=
 the
> bugzilla web interface).
>
> On Tue, 22 Jul 2008 03:21:33 -0700 (PDT) bugme-daemon-590EEB7GvNgfezExeAdx9g@public.gmane.org=
=2Eorg wrote:
>
>  =20
>> http://bugzilla.kernel.org/show_bug.cgi?id=3D11144
>>
>>            Summary: dhcp doesn't work with iwl4965
>>            Product: Networking
>>            Version: 2.5
>>      KernelVersion: 2.6.26-git7
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Wireless
>>         AssignedTo: networking_wireless-ztI5WcYan/vQLgFONoPN62D2FQJk+8+b@public.gmane.org
>>         ReportedBy: francois.valenduc-bmtTS95sd5BUM80lpFwj4w@public.gmane.org
>>
>>
>> Latest working kernel version: 2.6.26-git6
>> Earliest failing kernel version: 2.6.26-git7
>>    =20
>
> A very fresh regression.
>
>  =20
>> Distribution: Gentoo
>> Hardware Environment: Packard Bell MB86, iwl4965
>> Software Environment: dhcpcd
>> Problem Description:=20
>> I can't get an IP address via DHCP with my wireless connection. I ha=
ve an Intel
>> Wireless 4965 card and I use WPA personal with AES encryption. After=
 a
>> git-bisect run, it seems the first bad commit is the following:
>>
>> commit 175f9c1bba9b825d22b142d183c9e175488b260c
>> Author: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
>> Date:   Sun Jul 20 00:08:47 2008 -0700
>>
>>     net_sched: Add size table for qdiscs
>>
>>     Add size table functions for qdiscs and calculate packet size in
>>     qdisc_enqueue().
>>
>>     Based on patch by Patrick McHardy
>>      http://marc.info/?l=3Dlinux-netdev&m=3D115201979221729&w=3D2
>>
>>
>>    =20
>
> A whole pile of networking patches went into mainline about 12 hours
> ago, one of which might have fixed this.  Can you please test
> 2.6.26-git10 once it has appeared and let us know the result?
>
>
> Thanks.
>
>
>  =20

The problem still occurs with 2.6.26-git-10. But if I use a static=20
address instead of DHCP, the connection work. DHCP also work with my=20
ethernet card (a Marvell yukon which use the sky2 driver). But DHCP=20
doesn't work with my wireless connection using the iwl4965 driver. As I=
=20
said, my router offer several time a correct IP adress but it is not=20
accepted by my computer. I don't use traffic shaping (see my iptables=20
rules). Furthermore, the problem still occurs if I disable iptables.
Does anybody have an idea to solve the problem ?

Thanks for your help,
=46ran=E7ois

P.S: why don't you want to use the bugzilla interface ?
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
