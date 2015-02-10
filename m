From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Tue, 10 Feb 2015 07:04:11 +0100
Message-ID: <CAKfDRXhoTWXqf6QrvFiyMeDp6dyDDAoPOLkdKdXfj46E5q+hog@mail.gmail.com>
References: <CAKfDRXjwsQRA+CxaUpZVoDW3TmrUd6edSf_gi1EkPMcTFv0F5A@mail.gmail.com>
	<8761bbqker.fsf@nemi.mork.no>
	<CAKfDRXjhN7q98PKeddgoHhx8rFx+bf8YweTE62AbCfbi7v8E3w@mail.gmail.com>
	<20150209.141947.1972128292278697717.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
	Network Development <netdev@vger.kernel.org>,
	Aleksander Morgado <aleksander@aleksander.es>
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:53018 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbbBJGEM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 01:04:12 -0500
Received: by mail-yh0-f41.google.com with SMTP id 29so449591yhl.0
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 22:04:11 -0800 (PST)
In-Reply-To: <20150209.141947.1972128292278697717.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 9, 2015 at 11:19 PM, David Miller <davem@redhat.com> wrote:
> So what are we going to do with this patch?

I spent some more time yesterday reading through the references
provided by Bj=C3=B8rn, as well as doing some more searching. The devic=
es
exported by interface 8 and 10 offers the same functionality, and
interface 8 seems to work for all MC73xx-devices (there is no
reference of anyone not getting a connection through it). Interface
10, on the other hand, only seems to work on some MC73xx-devices. I
see no point in carrying around a reference in the driver to an
interface that might work in some cases, when there is one that always
works. However, there might be a modem or a particular firmware
revision I am not aware of. Bj=C3=B8rn/Aleksander knows more about
available QMI-devices than me, so I think they should decide.

-Kristian
