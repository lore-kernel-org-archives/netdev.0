From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Tue, 10 Feb 2015 12:39:32 +0100
Message-ID: <87h9uuatcb.fsf@nemi.mork.no>
References: <CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
	<8761bbqker.fsf@nemi.mork.no>
	<CAKfDRXjhN7q98PKeddgoHhx8rFx+bf8YweTE62AbCfbi7v8E3w@mail.gmail.com>
	<20150209.141947.1972128292278697717.davem@redhat.com>
	<874mqucije.fsf@nemi.mork.no>
	<CAAP7uc+UdthRu49NjKCm+7tZNf+hx0LFFn9Vspq3+OQsd4MDRg@mail.gmail.com>
	<CAAP7ucJo3CMwAZqkJ8jPHZgP0Sdh5_twdgPRu87p69nPXmGMpw@mail.gmail.com>
	<CAKfDRXhyS0fdonKryTLtr8PcJ60XbaxxZbynR3kfFKcfioB2tQ@mail.gmail.com>
	<CAAP7ucJMDcbvCw_1B33NOpWOoj4-or86MDQM9rw14Zs8KRUdxQ@mail.gmail.com>
	<CAKfDRXhQ5vDUw_0X-N8v9NhTwxo_Osc-JZtAorm0wjw9W5r+LA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Aleksander Morgado <aleksander@aleksander.es>,
	David Miller <davem@redhat.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:39780 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbbBJLjy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 06:39:54 -0500
In-Reply-To: <CAKfDRXhQ5vDUw_0X-N8v9NhTwxo_Osc-JZtAorm0wjw9W5r+LA@mail.gmail.com>
	(Kristian Evensen's message of "Tue, 10 Feb 2015 11:53:03 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kristian Evensen <kristian.evensen@gmail.com> writes:
> On Tue, Feb 10, 2015 at 11:37 AM, Aleksander Morgado
> <aleksander@aleksander.es> wrote:
>> With ModemManager you can use both WWAN interfaces by creating
>> independent Bearer objects and getting them connected independently
>> (e.g. to different APNs). Not sure if anyone will ever do that, but
>> well.
>
> Thanks for reminding me of this use case. One scenario where it makes
> sense is how IPv4/IPv6 is handled by some mobile broadband operators.
> I know of at least one Norwegian ISP that at least used different APN=
s
> for IPv4 and IPv6.

Sure, very useful for testing, although I don't think that they meant i=
t
that way.  I believe the assumption is that you get full Internet acces=
s
using either APN, with DNS64/NAT64/464XLAT for the IPv6 only one.

Other use cases I can think of:
 - dedicated MMS APN
 - dedicated voice APN
 - VPN APN(s)

all in combination with an Internet access APN.  So yes, two independen=
t
bearers are certainly useful.  I expect many modems will support more
than one bearer in the near future.  The Intel XMM7160 based modems,
like for example the Sierra Wireless EM7345, already support 8(!)


Bj=C3=B8rn
