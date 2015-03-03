From: Andy Zhou <azhou@nicira.com>
Subject: Re: [RFCv2 net-next 6/7] net: Refactor ip_defrag() APIs
Date: Tue, 3 Mar 2015 11:55:35 -0800
Message-ID: <CACzMAJ+Lsf-xshZZhdvp8dXTtGMb8spauBaKBqdajGimUdxbbw@mail.gmail.com>
References: <1425333305-19702-1-git-send-email-joestringer@nicira.com>
	<1425333305-19702-7-git-send-email-joestringer@nicira.com>
	<20150303082054.GA11110@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Stringer <joestringer@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Justin Pettit <jpettit@nicira.com>, Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:43032 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751500AbbCCTzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 14:55:36 -0500
Received: by mail-oi0-f54.google.com with SMTP id h136so1579715oig.1
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 11:55:35 -0800 (PST)
In-Reply-To: <20150303082054.GA11110@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ah, I missed it.  Currently it is passed via IPCB. Would it be better
to pass it as a parameter?

On Tue, Mar 3, 2015 at 12:20 AM, Patrick McHardy <kaber@trash.net> wrote:
> On 02.03, Joe Stringer wrote:
>> From: Andy Zhou <azhou@nicira.com>
>>
>> Currently, ip_defrag() does not keep track of the maximum fragmentation
>> size for each fragmented packet. This information is not necessary since
>> current Linux IP fragmentation always fragments a packet based on output
>> devices' MTU.
>
> It does, search for max_size.
