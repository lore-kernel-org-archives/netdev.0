From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH] net: provide capability and group sets via SCM
Date: Tue, 15 Feb 2011 10:09:00 -0800
Message-ID: <4D5AC13C.10000@schaufler-ca.com>
References: <4D3466BD.10500@schaufler-ca.com>	<4D51C38B.1060902@schaufler-ca.com> <20110214.174919.48492611.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ext-jarkko.2.sakkinen@nokia.com, Janne.Karhunen@nokia.com,
	elena.reshetova@nokia.com, Casey Schaufler <casey@schaufler-ca.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.prem.mail.sp1.yahoo.com ([98.136.44.62]:47711 "HELO
	smtp107.prem.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755572Ab1BOSJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 13:09:02 -0500
In-Reply-To: <20110214.174919.48492611.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/14/2011 5:49 PM, David Miller wrote:
> From: Casey Schaufler <casey@schaufler-ca.com>
> Date: Tue, 08 Feb 2011 14:28:27 -0800
>
>> Subject: [PATCH] net: provide group lists and capability set via CMSG
>>
>> Provide the namespace converted group list of the peer
>> process using the SCM mechanism. Provide the capability
>> set of the peer process. The capability set is not
>> namespace converted on the assumption that there is no
>> such conversion available or required.
>>
>> Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>
> You can't just hit the asm-generic header, you have to also hit
> all of the architectures that don't use the asm-generic header,
> including sparc, powerpc, mips, s390, arm, alpha, cris, frv, h8300,
> ia64, m32r, m68k, m68knommu, mn10300, parisc, and xtensa.

OK, I was afraid of that. Updated version will include those.
Thank you.


> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>

