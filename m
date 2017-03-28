From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCH RFC v4 10/10] tty: serdev: add functions to retrieve
 common UART settings
Date: Tue, 28 Mar 2017 18:33:45 +0200
Message-ID: <0e62c3e6-e225-f958-a4af-2f43093beb5b@i2se.com>
References: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
 <1490621848-24828-11-git-send-email-stefan.wahren@i2se.com>
 <CAL_JsqJ3b2zTGNHNVtt6Y+k23iw+2G2z-Jm2786a8CEzZBS7=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Sebastian Reichel <sre@kernel.org>,
        netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-serial@vger.kernel.org" <linux-serial@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rob Herring <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAL_JsqJ3b2zTGNHNVtt6Y+k23iw+2G2z-Jm2786a8CEzZBS7=g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 27.03.2017 um 22:00 schrieb Rob Herring:
> On Mon, Mar 27, 2017 at 8:37 AM, Stefan Wahren <stefan.wahren@i2se.com> wrote:
>> Currently serdev core doesn't provide functions to retrieve common
>> UART settings like data bits, stop bits or parity. This patch adds
>> the interface to the core and the necessary implementation for
>> serdev-ttyport.
> It doesn't provide them because why do you need to know? The attached
> device should request the settings it needs and be done with it. Maybe
> some devices can support a number of settings and you could want
> negotiate the settings with the UART, though surely 8N1 is in that
> list. It's rare to see something that's not 8N1 from what I've seen.

During development it's very helpful to check the current UART settings
and error counter. Currently i can't see a replacement for
/sys/class/tty/ttyXYZ .

Are there any plans about it?

>
> Rob
