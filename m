From: Santiago Garcia Mantinan <manty@manty.net>
Subject: Re: bonding + arp monitoring fails if interface is a vlan
Date: Wed, 7 Aug 2013 09:26:49 +0200
Message-ID: <CAJk_L2FTs0bX_s+ChKY9ZvZqVTagE=LQZpwV48b1RFhgtMsd8w@mail.gmail.com>
References: <20130801121142.GA444@www.manty.net>
	<51FB9EE5.3040907@redhat.com>
	<CAJk_L2FJyD2X7EPztiVWLBD4NDR_VOehdFEeV+nq7a+sO9+_wA@mail.gmail.com>
	<CAJk_L2FU6GcHUoC+UdNJoULN9KewoUQAMhapC0k3RcTqNOymnw@mail.gmail.com>
	<51FF7DC6.7080602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f48.google.com ([209.85.128.48]:45589 "EHLO
	mail-qe0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077Ab3HGH0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 03:26:50 -0400
Received: by mail-qe0-f48.google.com with SMTP id 9so788428qea.7
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 00:26:50 -0700 (PDT)
In-Reply-To: <51FF7DC6.7080602@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/8/5 Nikolay Aleksandrov <nikolay@redhat.com>:
>>         bond-arp_validate 0
> No, because we take the first non-vlan's interface trans_start after the patch
> which in this case is a bonding interface which also doesn't update its
> trans_start, i.e. bond over bond (or over vlans over bond) with arp monitoring
> shouldn't work.

Ok, after several days of testing it seems to work ok if I go with
arp_validate 0, going for arp_validate 1 would cause the link failure
count to be increased from time to time, is this ok?

Regards.
-- 
Manty/BestiaTester -> http://manty.net
