From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Mon, 20 Jan 2014 16:12:53 +0400
Message-ID: <52DD12C5.1070607@cogentembedded.com>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com> <CAMuHMdWZJUvcW9OzM39aB2m+VdKqmZ6EOGR_rZcAdV7Cmwx3kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wg@grandegger.com, mkl@pengutronix.de, linux-can@vger.kernel.org,
	Linux-sh list <linux-sh@vger.kernel.org>, vksavl@gmail.com
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWZJUvcW9OzM39aB2m+VdKqmZ6EOGR_rZcAdV7Cmwx3kg@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 20-01-2014 15:43, Geert Uytterhoeven wrote:

>> Changes in version 3:

>> - added '__packed' to 'struct rcar_can_mbox_regs' and 'struct rcar_can_regs';
>> - removed unneeded type cast in the probe() method.

>> +/* Mailbox registers structure */
>> +struct rcar_can_mbox_regs {
>> +       u32 id;         /* IDE and RTR bits, SID and EID */
>> +       u8 stub;        /* Not used */
>> +       u8 dlc;         /* Data Length Code - bits [0..3] */
>> +       u8 data[8];     /* Data Bytes */
>> +       u8 tsh;         /* Time Stamp Higher Byte */
>> +       u8 tsl;         /* Time Stamp Lower Byte */
>> +} __packed;

> Sorry, I missed the earlier discussion, but why the _packed?
> One u32 and 12 bytes makes a nice multiple of 4.

    Mainly for consistency as this is a structure representing the hardware 
registers.

> Gr{oetje,eeting}s,

>                          Geert

WBR, Sergei

