From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support for GEM
Date: Fri, 18 Nov 2016 16:02:03 +0530
Message-ID: <CAFcVEC+ft7FG2VYo21ifjv4ms+k2_BA98NAtP+Ppudx_8HUYeQ@mail.gmail.com>
References: <BN3PR07MB2516B2EBCF0AE7079971DBF6C9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVECJ-ZYjGg-3CbWD2Ka8yKzOokUxS8ZHHOJXa2Z6anuTr7Q@mail.gmail.com>
 <e6773b4e-a633-4754-893d-fd2351d07459@atmel.com> <BN3PR07MB2516EBCDD8822FC5F8A9095FC9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVEC+RqUMQF39oe2EuCoisX6dCwRQ3G81zFMqoOHU3HpfPHQ@mail.gmail.com>
 <BN3PR07MB25166D8301C60C4A35402AB1C9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
 <a315b554-8b44-ac82-a104-e382940750bb@atmel.com> <BN3PR07MB251655CAFDB38CCF0F240BB5C9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVECJT=b2jmQAtsTeXEwWad8L2VEVW1GOyTY9XYR5qUq=4Mw@mail.gmail.com> <27516aeb-b8f9-dc38-4d01-d2a5c5cf44dd@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rafal Ozieblo <rafalo@cadence.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrei Pistirica <andrei.pistirica@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <27516aeb-b8f9-dc38-4d01-d2a5c5cf44dd@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tHi Andrei,

>> Yes, Andre's version of Cadence does not ability to report have RX
>> timestamp.
>> The version I worked with did. This is the old series I sent:
>> https://lkml.org/lkml/2015/9/11/92
>> But right now, i'm working on building on top of Andre's changes.
>
>
> I'm addressing maintainer's feedback on both patches:
> https://patchwork.kernel.org/patch/9310989/
> https://patchwork.kernel.org/patch/9310991/
>
> I've done all suggested updates, except the numerous 64bit divisions in the
> frequency adjustment callback. I've implemented a different algorithm which
> uses 2 64bit division, but I couldn't find a way to use only 1.
>
> Also, I have a version with timecounter/cyclecounter which shows a much
> better accuracy (less than 100ns level). In my opinion this could be a
> better implementation. What is you opinion about this? Did you try it?
>

I did not try timecounter on Cadence IP versions later than r1p06.
Because with sub ns precision in HW timestamp, that works better
than SW cyclecounter.
On older Zynq version, yes timecounter is used and is better.

Regards,
Harini
