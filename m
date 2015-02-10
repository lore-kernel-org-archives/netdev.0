From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Tue, 10 Feb 2015 10:18:36 +0100
Message-ID: <CAKfDRXhyS0fdonKryTLtr8PcJ60XbaxxZbynR3kfFKcfioB2tQ@mail.gmail.com>
References: <CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
	<8761bbqker.fsf@nemi.mork.no>
	<CAKfDRXjhN7q98PKeddgoHhx8rFx+bf8YweTE62AbCfbi7v8E3w@mail.gmail.com>
	<20150209.141947.1972128292278697717.davem@redhat.com>
	<874mqucije.fsf@nemi.mork.no>
	<CAAP7uc+UdthRu49NjKCm+7tZNf+hx0LFFn9Vspq3+OQsd4MDRg@mail.gmail.com>
	<CAAP7ucJo3CMwAZqkJ8jPHZgP0Sdh5_twdgPRu87p69nPXmGMpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
	David Miller <davem@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:53002 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbbBJJSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 04:18:37 -0500
Received: by mail-yh0-f52.google.com with SMTP id f73so788073yha.11
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 01:18:36 -0800 (PST)
In-Reply-To: <CAAP7ucJo3CMwAZqkJ8jPHZgP0Sdh5_twdgPRu87p69nPXmGMpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 9:51 AM, Aleksander Morgado
<aleksander@aleksander.es> wrote:
>> The only case in which I've seen such a modem (a MC7304) with 1 single
>> valid QMI interface (actually being #8) is when the modem is put in
>> "single-qmi" interface mode, which you can do forcing it to get the
>> MC7710 PID, e.g. AT!UDPID=68A2. But otherwise, if the modem was
>> exposed as 0x68c0, if#10 always worked for me...

My modem has the expected PID (0x68c0).

> BTW, regarding the patch... if interface #10 ends up being usable only
> in some 73xx models, I would still leave it available anyway in the
> kernel driver. Userspace can always figure out whether the interface
> is usable or not (e.g. MM does some QMI probing on the interface
> before flagging it as usable).

I will not fight strongly for this patch. My motivation was mostly to
clean up, since it looks a bit messy keeping an additional interface +
cdc-wdm device around which will never be used (and can be avoided).

> A similar issue we had with if#11 IIRC, which the sierra driver marked
> it as being QMI but we never made it work once, so we ended up
> removing it from qmi_wwan (see commit fc0d6e9cd0a). Now I wonder if we
> should have done that only by testing it once with my hw.

Interface 11 does not reply on my device as well.

-Kristian
