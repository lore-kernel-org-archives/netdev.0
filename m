From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] bridge: mcast: when multicast is disabled flush
 the groups
Date: Wed, 22 Jul 2015 10:03:43 -0700
Message-ID: <CAHA+R7PTV5aTk2JyaaCQ1awi_Cwz+jzA4tv9n2nEvaFxhuD0Pg@mail.gmail.com>
References: <1437560929-25827-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Satish Ashok <sashok@cumulusnetworks.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:33465 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500AbbGVRDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 13:03:44 -0400
Received: by ykfw194 with SMTP id w194so117630010ykf.0
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 10:03:43 -0700 (PDT)
In-Reply-To: <1437560929-25827-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 22, 2015 at 3:28 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> From: Satish Ashok <sashok@cumulusnetworks.com>
>
> Once multicast gets disabled we should flush the groups.
> Example:
> # bridge mdb add dev br0 port eth3 grp 239.0.0.1
> # bridge mdb
> dev br0 port eth3 grp 239.0.0.1 temp
> # echo 0 > multicast_snooping
> # bridge mdb

Why? Why we can't save the mdb config for a mcast snooping flip?
