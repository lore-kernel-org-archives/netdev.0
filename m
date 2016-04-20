From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Wed, 20 Apr 2016 14:48:28 +0200
Message-ID: <20160420144828.5537dce7@griffin>
References: <20160418.214851.122286645854721047.davem@davemloft.net>
	<20160418.235207.395468709808133833.davem@davemloft.net>
	<1461060543.2766.20.camel@sipsolutions.net>
	<20160419.142324.1774057494079734967.davem@davemloft.net>
	<1461094901.2766.26.camel@sipsolutions.net>
	<5716E123.8040002@cumulusnetworks.com>
	<1461137540.2176.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com,
	egrumbach@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47767 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750941AbcDTMse convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 08:48:34 -0400
In-Reply-To: <1461137540.2176.5.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Apr 2016 09:32:20 +0200, Johannes Berg wrote:
> 2) Use the new attribute flag with some required attribute for
> =C2=A0 =C2=A0existing commands, so that older kernel will not find th=
e required
> =C2=A0 =C2=A0attribute and will reject the operation entirely.
> =C2=A0 =C2=A0May or may not fall back to trying the operation again w=
ithout the
> =C2=A0 =C2=A0flag.

This is basically what I submitted half a year ago. See:
http://thread.gmane.org/gmane.linux.network/382850

 Jiri
