From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] vrf: vrf_master_ifindex_rcu is not always called with rcu read lock
Date: Tue, 18 Aug 2015 23:24:27 +0300
Message-ID: <8DFB69F7-1CA6-4855-9C16-75919563E26C@cumulusnetworks.com>
References: <1439914666-7561-1-git-send-email-razor@blackwall.org> <1439921754-19715-1-git-send-email-razor@blackwall.org> <55D39128.1040804@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	davem@davemloft.net
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:34619 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbbHRUYc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 16:24:32 -0400
Received: by wicne3 with SMTP id ne3so109970184wic.1
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 13:24:30 -0700 (PDT)
In-Reply-To: <55D39128.1040804@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Aug 18, 2015, at 11:10 PM, David Ahern <dsa@cumulusnetworks.com> w=
rote:
>=20
> On 8/18/15 12:15 PM, Nikolay Aleksandrov wrote:
>> diff --git a/include/net/vrf.h b/include/net/vrf.h
>> index 3bb4af462ed6..b039850a94a3 100644
>> --- a/include/net/vrf.h
>> +++ b/include/net/vrf.h
>> @@ -34,7 +34,6 @@ struct net_vrf {
>>=20
>>=20
>>  #if IS_ENABLED(CONFIG_NET_VRF)
>> -/* called with rcu_read_lock() */
>>  static inline int vrf_master_ifindex_rcu(const struct net_device *d=
ev)
>>  {
>>  	struct net_vrf_dev *vrf_ptr;
>=20
> That comment is true for this version.
>=20
> David
>=20

It is, but as we established the name implies the same. Anyway I=92ll p=
ost a v3 and
keep it.
