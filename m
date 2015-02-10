From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Tue, 10 Feb 2015 11:53:03 +0100
Message-ID: <CAKfDRXhQ5vDUw_0X-N8v9NhTwxo_Osc-JZtAorm0wjw9W5r+LA@mail.gmail.com>
References: <CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
	<8761bbqker.fsf@nemi.mork.no>
	<CAKfDRXjhN7q98PKeddgoHhx8rFx+bf8YweTE62AbCfbi7v8E3w@mail.gmail.com>
	<20150209.141947.1972128292278697717.davem@redhat.com>
	<874mqucije.fsf@nemi.mork.no>
	<CAAP7uc+UdthRu49NjKCm+7tZNf+hx0LFFn9Vspq3+OQsd4MDRg@mail.gmail.com>
	<CAAP7ucJo3CMwAZqkJ8jPHZgP0Sdh5_twdgPRu87p69nPXmGMpw@mail.gmail.com>
	<CAKfDRXhyS0fdonKryTLtr8PcJ60XbaxxZbynR3kfFKcfioB2tQ@mail.gmail.com>
	<CAAP7ucJMDcbvCw_1B33NOpWOoj4-or86MDQM9rw14Zs8KRUdxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
	David Miller <davem@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:47167 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbbBJKxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 05:53:04 -0500
Received: by mail-yh0-f42.google.com with SMTP id i57so7090596yha.1
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 02:53:03 -0800 (PST)
In-Reply-To: <CAAP7ucJMDcbvCw_1B33NOpWOoj4-or86MDQM9rw14Zs8KRUdxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 11:37 AM, Aleksander Morgado
<aleksander@aleksander.es> wrote:
> With ModemManager you can use both WWAN interfaces by creating
> independent Bearer objects and getting them connected independently
> (e.g. to different APNs). Not sure if anyone will ever do that, but
> well.

Thanks for reminding me of this use case. One scenario where it makes
sense is how IPv4/IPv6 is handled by some mobile broadband operators.
I know of at least one Norwegian ISP that at least used different APNs
for IPv4 and IPv6.

-Kristian
