From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: Re: [PATCH net] net: sctp: fix smatch warning in sctp_send_asconf_del_ip
Date: Sat, 7 Sep 2013 22:21:10 +0200
Message-ID: <0DF62EB6-A1DB-46CB-971E-7858FB9D3FB7@sfc.wide.ad.jp>
References: <1378579881-27881-1-git-send-email-dborkman@redhat.com> <B8C81C0E-1D13-40A9-A39F-4E5C8069366D@sfc.wide.ad.jp> <522B8A45.4030005@redhat.com>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:51027 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751834Ab3IGUVR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 16:21:17 -0400
In-Reply-To: <522B8A45.4030005@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I understand, thanks!

Cheers,
- Michio

On Sep 7, 2013, at 10:19 PM, Daniel Borkmann wrote:

> On 09/07/2013 09:40 PM, Michio Honda wrote:
>> Hi,
>> 
>> Sorry for that I didn't respond to that warning.
>> You are right, laddr == NULL && addrcnt == 1 is the indicator of the function called by
>> asconf_mgmt().
>> 
>> Since your patch is actually redundant, I would suggest putting comment on the
>> line of "if ((laddr == NULL) && (addrcnt == 1)) {", and/or on the checking in your patch.
> 
> I think as is is just fine. One can read through the Git log and then see
> the rationale behind a change (which is in most cases even more worth than
> a comment). If this function should ever be called from somewhere else for
> whatever reason, then this comment would already be obsolete.
> 
