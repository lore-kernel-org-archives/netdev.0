From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: Understanding what's going on when using a Huawei E173 USB 3G
 web-stick (UMTS/HSPA)
Date: Wed, 12 Nov 2014 14:34:02 +0100
Message-ID: <CA+icZUXf==V1TXhJLSAp+05sWjwoVkFf_-DU6pHwD8reOO3ojQ@mail.gmail.com>
References: <CA+icZUXgLhuVSs0aqxi_e=GLZh-zX3JPMhDF+03ctr7O-Ae2og@mail.gmail.com>
	<1415120132.31049.11.camel@dcbw.local>
	<CAAP7ucKO2D8B1gG943aNcqWuLm2UWt3AsfZAh5bzeaA1gzSaHQ@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Williams <dcbw@redhat.com>, Greg KH <greg@kroah.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-usb@vger.kernel.org
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:36217 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556AbaKLNeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 08:34:04 -0500
In-Reply-To: <CAAP7ucKO2D8B1gG943aNcqWuLm2UWt3AsfZAh5bzeaA1gzSaHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2014 at 12:51 PM, Aleksander Morgado
<aleksander@aleksander.es> wrote:
>
> On Tue, Nov 4, 2014 at 5:55 PM, Dan Williams <dcbw@redhat.com> wrote:
>>
>> > The next mystery is what is network-manager doing in the background?
>> > I have seen that modem-manager is invoked, but as said I would like to
>> > understand the "internas" (means check the logs, turn on some
>> > debugging kernel-space/user-space, etc.).
>>
>> NetworkManager uses ModemManager for all WWAN control, NM only handles
>> the configuration storage and IP addressing parts of the setup.
>> ModemManager handles modem hardware detection, capability detection,
>> WWAN registration and setup, signal strength reporting, network
>> connection initiation, and bearer IP addressing method determination.
>>
>> If you want more information from ModemManager, you can run "mmcli
>> --help" or "mmcli --set-logging=debug".
>
>
> That (mmcli) will only be available in ModemManager >= 1.x, BTW. And beware
> of --set-logging=debug, as syslog may limit those if MM sends too many too
> fast. In general I usually prefer to ask for --debug output just in case:
> http://www.freedesktop.org/wiki/Software/ModemManager/Debugging/
>
> I saw the reporter talk about Ubuntu Precise (12.04) and Trusty (14.04), so
> only in the latter mmcli will be available (if I'm not mistaken). For
> Precise, this Ubuntu page shows how to enable debug logs:
> https://wiki.ubuntu.com/DebuggingModemmanager
>

Hi Aleksander,

thanks for the web-links.
IMHO both can be placed in the "usb-wwan-networking" documentation I
have in mind.
The fdo-weblink is distro-independant.

Regards,
- Sedat -
