From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: Warning when unloading the nf_conntack module (regression?)
Date: Sun, 3 Aug 2008 23:46:39 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0808032344510.16818@bizon.gios.gov.pl>
References: <20080803143730.7747e9a8@infradead.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-326322370-1217799999=:16818"
Cc: netdev@vger.kernel.org, kaber@trash.net
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:58127 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756682AbYHCVrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 17:47:39 -0400
In-Reply-To: <20080803143730.7747e9a8@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-326322370-1217799999=:16818
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Sun, 3 Aug 2008, Arjan van de Ven wrote:

> The warning below started showing up on kerneloops.org in the top 20 and =
it appears to
> be new in 2.6.27-rc (e.g. a regression)...
>
> It happens when nf_conntrack is rmmod'd
>
>
> The reports:
> http://www.kerneloops.org/search.php?search=3Dnf_conntrack_acct_fini
>
> The warning:
>
> WARNING: at kernel/sysctl.c:1966 unregister_sysctl_table+0xcc/0x103()
>
> Modules : nf_conntrack(-)
>
> Call Trace:
> [<ffffffff81043bc8>] warn_on_slowpath+0x65/0x98
> [<ffffffff8104abdf>] unregister_sysctl_table+0xcc/0x103
> [<ffffffffa0306655>] nf_conntrack_acct_fini+0x15/0x23 [nf_conntrack]
> [<ffffffffa03018a1>] nf_conntrack_cleanup+0x84/0x86 [nf_conntrack]
> [<ffffffffa0306944>] nf_conntrack_standalone_fini+0x40/0x42 [nf_conntrack=
]
> [<ffffffff810700d0>] sys_delete_module+0x202/0x263
> [<ffffffff8101034a>] system_call_fastpath+0x16/0x1b

Thanks. It seems I'm the person who introduced it. I'll look at it ASAP.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-326322370-1217799999=:16818--
