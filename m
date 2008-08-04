From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: RES: [Bugme-new] [Bug 11249] New: TC HTB hanging problem
Date: Mon, 04 Aug 2008 23:59:27 +0200
Message-ID: <48977BBF.4090705@gmail.com>
References: <bug-11249-10286@http.bugzilla.kernel.org/> <20080804105506.8b401320.akpm@linux-foundation.org> <BAY111-DAV13CEE254838554E11B28A0C0780@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: 'Andrew Morton' <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Leandro Oliveira da Silva <lansoweb@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.176]:40762 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755527AbYHDV7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 17:59:51 -0400
Received: by ik-out-1112.google.com with SMTP id c28so2759644ika.5
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2008 14:59:49 -0700 (PDT)
In-Reply-To: <BAY111-DAV13CEE254838554E11B28A0C0780@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Leandro Oliveira da Silva wrote, On 08/04/2008 08:44 PM:
...

> Just to add, 2 weeks ago one of my clients had to reboot the server 3 times
> during the day, so I disabled the qos and it worked fine for 3 days. After
> this days I started the qos again and 10 hours later the server hanged
> again, so it's disabled until now without hanging.

Hi,

There were a few bugs found for these kernels, but alas not all stable
versions were fixed. The best thing would be trying eg. 2.6.25.14 or 2.6.26.

Otherwise you could especially check these two patches:

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.25.y.git;a=commit;h=066a3b5b2346febf9a655b444567b7138e3bb939
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.25.y.git;a=commit;h=734bf48fe5276f319464fd30dc4a046a29d2b94a

Alas some HTB (or around) problems are still diagnosed, so this could be not
enough.

Regards,
Jarek P.
