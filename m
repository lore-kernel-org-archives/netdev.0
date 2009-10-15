From: =?ISO-8859-2?Q?Krzysztof_Ol=EAdzki?= <ole@ans.pl>
Subject: Re: [Patch] (updated) netfilter: remove deprecated CONFIG_NF_CT_ACCT
Date: Thu, 15 Oct 2009 14:04:18 +0200
Message-ID: <4AD70FC2.5050302@ans.pl>
References: <20091015080211.4561.78538.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:46096 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757499AbZJOMFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 08:05:17 -0400
In-Reply-To: <20091015080211.4561.78538.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[resend, previously I incorrectly copied netfilter-devel-owner]

Adding CC to netfilter-devel@vger.kernel.org, where netfilter
related issues are discussed.

On Thu, 15 Oct 2009, Amerigo Wang wrote:

>
> CONFIG_NF_CT_ACCT is scheduled to be removed in 2.6.29.
>
> Cc: Krzysztof Piotr Oledzki <ole@ans.pl>
> Signed-off-by: WANG Cong <amwang@redhat.com>

This is not so easy - it was decided that we don't want to remove it=20
just that because of connbytes. The final conclusion was to keep it=20
disabled by default (if not enabled by kernel/modules/sysctl option) bu=
t=20
enabling it automatically for the current NS if nefilter rules contains=
=20
"-m connbytes".

Sorry, I should have gotten into this and finished it earlier, my bad. =
:(

Best regards,

  				Krzysztof Ol=EAdzki
