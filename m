From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] inet: restore gso for vxlan
Date: Sat, 16 Nov 2013 12:50:29 -0800
Message-ID: <1384635029.8604.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	 <1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	 <1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131025.181809.348808013109842304.davem@davemloft.net>
	 <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
	 <1382923096.13037.10.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383863586.9412.101.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuwqmUhTgeKyodGKmOxhxe23=umnfc7nouhdVrqVNnk6zQ@mail.gmail.com>
	 <CAJZOPZ+96PudQJabptvb_h5qLLyEVPWruK6mJUh7Z9FW8wk6+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:43423 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584Ab3KPUub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 15:50:31 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so3351379pdj.30
        for <netdev@vger.kernel.org>; Sat, 16 Nov 2013 12:50:31 -0800 (PST)
In-Reply-To: <CAJZOPZ+96PudQJabptvb_h5qLLyEVPWruK6mJUh7Z9FW8wk6+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-11-16 at 22:23 +0200, Or Gerlitz wrote:

> Guys, just to clarify, is this fixed by now? where, net-next?

Should be fixed on all trees :

commit dcd607718385d02ce3741de225927a57f528f93b
("inet: fix a UFO regression")
