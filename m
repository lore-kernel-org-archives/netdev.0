From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/1][PKT_CLS] Avoid multiple tree locks
Date: Wed, 21 Mar 2007 06:38:11 -0400
Message-ID: <1174473491.16343.12.camel@localhost>
References: <1174471116.16343.10.camel@localhost>
	 <4601047A.6050108@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.225]:24026 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722AbXCUKiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 06:38:19 -0400
Received: by nz-out-0506.google.com with SMTP id s1so164571nze
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2007 03:38:18 -0700 (PDT)
In-Reply-To: <4601047A.6050108@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-21-03 at 11:10 +0100, Patrick McHardy wrote:

> Its harmless since its a read lock, which can be nested. I actually
> don't see any need for qdisc_tree_lock at all, all changes and all
> walking is done under the RTNL, which is why I've removed it in
> my (upcoming) patches. I suggest to leave it as is for now so I
> don't need to change the __qdisc_lookup back to qdisc_lookup in
> 2.6.22.

Sounds good to me.

cheers,
jamal

