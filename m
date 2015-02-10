From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Tue, 10 Feb 2015 11:37:51 +0100
Message-ID: <CAAP7ucJMDcbvCw_1B33NOpWOoj4-or86MDQM9rw14Zs8KRUdxQ@mail.gmail.com>
References: <CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
	<8761bbqker.fsf@nemi.mork.no>
	<CAKfDRXjhN7q98PKeddgoHhx8rFx+bf8YweTE62AbCfbi7v8E3w@mail.gmail.com>
	<20150209.141947.1972128292278697717.davem@redhat.com>
	<874mqucije.fsf@nemi.mork.no>
	<CAAP7uc+UdthRu49NjKCm+7tZNf+hx0LFFn9Vspq3+OQsd4MDRg@mail.gmail.com>
	<CAAP7ucJo3CMwAZqkJ8jPHZgP0Sdh5_twdgPRu87p69nPXmGMpw@mail.gmail.com>
	<CAKfDRXhyS0fdonKryTLtr8PcJ60XbaxxZbynR3kfFKcfioB2tQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
	David Miller <davem@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:50746 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbbBJKhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 05:37:52 -0500
Received: by mail-oi0-f44.google.com with SMTP id a3so16903042oib.3
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 02:37:51 -0800 (PST)
In-Reply-To: <CAKfDRXhyS0fdonKryTLtr8PcJ60XbaxxZbynR3kfFKcfioB2tQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 10:18 AM, Kristian Evensen
<kristian.evensen@gmail.com> wrote:
>> BTW, regarding the patch... if interface #10 ends up being usable only
>> in some 73xx models, I would still leave it available anyway in the
>> kernel driver. Userspace can always figure out whether the interface
>> is usable or not (e.g. MM does some QMI probing on the interface
>> before flagging it as usable).
>
> I will not fight strongly for this patch. My motivation was mostly to
> clean up, since it looks a bit messy keeping an additional interface +
> cdc-wdm device around which will never be used (and can be avoided).

With ModemManager you can use both WWAN interfaces by creating
independent Bearer objects and getting them connected independently
(e.g. to different APNs). Not sure if anyone will ever do that, but
well.

-- 
Aleksander
https://aleksander.es
