From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3] fs: allow for more than 2^31 files
Date: Fri, 01 Oct 2010 07:03:54 +0200
Message-ID: <1285909434.2705.35.camel@edumazet-laptop>
References: <20100923121704.GR14064@sgi.com>
	 <1285246384.362.3.camel@edumazet-laptop> <20100923141037.GA3811@in.ibm.com>
	 <20100927.153639.212415479.davem@davemloft.net>
	 <1285645611.10438.27.camel@edumazet-laptop>
	 <20100930202612.GM14068@sgi.com> <1285879545.2705.4.camel@edumazet-laptop>
	 <20101001043413.GN14068@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, dipankar@in.ibm.com,
	viro@zeniv.linux.org.uk, bcrl@kvack.org, den@openvz.org,
	mingo@elte.hu, mszeredi@suse.cz, cmm@us.ibm.com, npiggin@kernel.dk,
	xemul@openvz.org, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Robin Holt <holt@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34684 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535Ab0JAFEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 01:04:01 -0400
In-Reply-To: <20101001043413.GN14068@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 30 septembre 2010 =C3=A0 23:34 -0500, Robin Holt a =C3=A9crit =
:

> The proc_handler used to be proc_nr_files() which would call
> get_nr_files() and deposit the result in files_stat.nr_files then cas=
cade
> to proc_dointvec() which would dump the 3 values.  Now it will dump t=
he
> three values, but not update the middle (nr_files) value first.
>=20

Ah I get it now, thanks !

I'll send a V4 shortly.



