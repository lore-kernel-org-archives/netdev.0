From: "Leandro Oliveira da Silva" <lansoweb@hotmail.com>
Subject: RES: RES: [Bugme-new] [Bug 11249] New: TC HTB hanging problem
Date: Tue, 5 Aug 2008 09:13:15 -0300
Message-ID: <BAY111-DAV13F1322A6C6496A77566F8C07B0@phx.gbl>
References: <bug-11249-10286@http.bugzilla.kernel.org/> <20080804105506.8b401320.akpm@linux-foundation.org> <BAY111-DAV13CEE254838554E11B28A0C0780@phx.gbl> <48977BBF.4090705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Andrew Morton'" <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>, <bugme-daemon@bugzilla.kernel.org>
To: "'Jarek Poplawski'" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s26.bay0.hotmail.com ([65.54.246.98]:36995 "EHLO
	bay0-omc1-s26.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757121AbYHEMNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 08:13:21 -0400
In-Reply-To: <48977BBF.4090705@gmail.com>
Message-ID: <000601c8f6f4$a3853b90$ea8fb2b0$@com>
Content-Language: pt-br
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jarek!

Many thanks for your response! Are these two patches already included in
2.6.26 version?

Thanks a lot again,
Leandro

-----Mensagem original-----
De: Jarek Poplawski [mailto:jarkao2@gmail.com] 
Enviada em: segunda-feira, 4 de agosto de 2008 18:59
Para: Leandro Oliveira da Silva
Cc: 'Andrew Morton'; netdev@vger.kernel.org;
bugme-daemon@bugzilla.kernel.org
Assunto: Re: RES: [Bugme-new] [Bug 11249] New: TC HTB hanging problem

Leandro Oliveira da Silva wrote, On 08/04/2008 08:44 PM:
..

> Just to add, 2 weeks ago one of my clients had to reboot the server 3
times
> during the day, so I disabled the qos and it worked fine for 3 days. After
> this days I started the qos again and 10 hours later the server hanged
> again, so it's disabled until now without hanging.

Hi,

There were a few bugs found for these kernels, but alas not all stable
versions were fixed. The best thing would be trying eg. 2.6.25.14 or 2.6.26.

Otherwise you could especially check these two patches:

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.25.y.git;a=commit
;h=066a3b5b2346febf9a655b444567b7138e3bb939
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.25.y.git;a=commit
;h=734bf48fe5276f319464fd30dc4a046a29d2b94a

Alas some HTB (or around) problems are still diagnosed, so this could be not
enough.

Regards,
Jarek P.

