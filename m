From: pidoux <bpidoux@free.fr>
Subject: Re: [PATCH][ROSE][NETROM] display neigh instead of address
Date: Sun, 09 Mar 2008 10:00:09 +0100
Message-ID: <47D3A719.9080105@free.fr>
References: <20080211124251.GB3597@ff.dom.local>	<20080211.212659.228544422.davem@davemloft.net>	<47C88AEF.4050504@free.fr> <20080303.205304.225449154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f6bvp@free.fr, ralf@linux-mips.org, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20080303.205304.225449154.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Bernard Pidoux F6BVP <f6bvp@free.fr>
> Date: Fri, 29 Feb 2008 23:45:03 +0100
>
>  =20
>> I submit the following patch against kernel 2.6.24.3 to replace
>> labels "addr" in /proc/net/rose_neigh and /proc/net/nr_neigh
>> by labels "neigh" for the display of neighbour numbers in the
>> first columns.
>>
>> This makes the reading of proc more consistent with the labels of
>> /proc/net/rose_nodes and /proc/net/nr_nodes.
>> Finding the callsign of a given node neighbour number becomes easier=
=2E
>>    =20
>
> I'm not so sure there is much value to this.
> "address", "neigh", it's all about the same.
>
> Yes, it's inconsistent in various areas, but procfs
> output is like a fixed API with userspace and we generally
> cannot change it without potentially breaking userspace.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>  =20
I thought that the patch would only affect /proc/net/rose and=20
/proc/net/netrom, not /proc/net.
However I understand your objection.
Meanwhile application programs can deal with the present labels as far=20
as we keep in mind that "addr" and "neigh" are talking about the same t=
hing.
Thanks for the explanation.

Bernard Pidoux

=20
--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
