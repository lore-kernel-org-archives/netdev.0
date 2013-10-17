From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] fib_trie: Send RTM_DELROUTE when link goes down
Date: Thu, 17 Oct 2013 22:11:39 +0200
Message-ID: <CAKfDRXiM-8dnGqFMofdiaD=EMJNLxzx-yhVManRSiQHgziuVdQ@mail.gmail.com>
References: <CAKfDRXizw1TaK-oHrAQv8Hi80gKiUHjQ6d21o3MOQpuVkcXSow@mail.gmail.com>
	<1382028894-14236-1-git-send-email-kristian.evensen@gmail.com>
	<alpine.LFD.2.03.1310172245440.2016@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:43654 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762555Ab3JQULk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 16:11:40 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so2779002pbc.16
        for <netdev@vger.kernel.org>; Thu, 17 Oct 2013 13:11:40 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.03.1310172245440.2016@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Oct 17, 2013 at 9:52 PM, Julian Anastasov <ja@ssi.bg> wrote:
>         IIRC, such notifications were not implemented
> to avoid storms to routing daemons. Not sure if this is
> still true.

Thanks for letting me know. I was wondering if this was the case, but
then I saw that the deletion of IPv6 routes are announced (when
running "ip link set dev X down") and assumed that message storms was
(is?) not considered a problem.

-Kristian
