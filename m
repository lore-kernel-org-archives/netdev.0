From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: PROBLEM: Bridging does not work with Mellanox ConnectX-2
 (mlx4_en) card in SR-IOV mode
Date: Tue, 25 Jun 2013 08:36:18 +0300
Message-ID: <CAJZOPZ+izFj+8FycCjLd-jD5E8dV+F=gLkxFUaJVA0sQi3XhmA@mail.gmail.com>
References: <CAJA5wJQDRztwtMxJopUWfmqEOH39Xp0g-hCrY8gMZ2TKccSuhw@mail.gmail.com>
	<CAJZOPZLCG8_zfsP76EnEcGj3nUfP9batXMfvOqsPyNc63JqLSA@mail.gmail.com>
	<CAJA5wJRW1gai3pRXRD1fugrXQJxsJ3PDzVkLqWqjxvF-ixAheg@mail.gmail.com>
	<CAJA5wJSQiCbmNgv14yENe4PQtRxKeEC0KTcgVow4LnE-thyp2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Ryousei Takano <takano-ryousei@aist.go.jp>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Amir Vadai <amirv@mellanox.com>, Yan Burman <yanb@mellanox.com>
To: Pawit Pornkitprasan <p.pawit@gmail.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:43185 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006Ab3FYFgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 01:36:19 -0400
Received: by mail-qa0-f51.google.com with SMTP id f11so341925qae.10
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 22:36:18 -0700 (PDT)
In-Reply-To: <CAJA5wJSQiCbmNgv14yENe4PQtRxKeEC0KTcgVow4LnE-thyp2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 25, 2013 at 3:46 AM, Pawit Pornkitprasan <p.pawit@gmail.com> wrote:
> On Tue, Jun 25, 2013 at 7:45 AM, Pawit Pornkitprasan <p.pawit@gmail.com> wrote:
>>
>> Thank you. I will try it out.
>>
>
> Update: I've tried "sudo bridge fdb add [target mac address] dev p4p1"
> and the bridge is working properly. Is there any reason why the
> bridging code cannot do this automatically?

Good question, there is some ongoing work in that direction but I am
not sure where things stand now, I added Michael and Vlad who are
involved in that adventure.
