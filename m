From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2 2/4] can: fixed-transceiver: Add documentation for CAN
 fixed transceiver bindings
Date: Fri, 28 Jul 2017 10:41:40 +0200
Message-ID: <b6ee18fa-a72b-9596-00d8-f6bd4a993293@hartkopp.net>
References: <20170724230521.1436-1-fcooper@ti.com>
 <20170724230521.1436-3-fcooper@ti.com> <20170726164124.GL12049@lunn.ch>
 <355b90b3-97ce-1057-6617-d5d709449c48@hartkopp.net>
 <a77fe395-33c7-9405-b51a-5d3372e5c58b@ti.com>
 <fe99189e-d077-ba65-4dfc-a4d8beee62b3@hartkopp.net>
 <932602fe-d06a-7a17-5a0c-24265cf2e643@ti.com>
 <20170728045724.GA27903@airbook.vandijck-laurijssen.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Franklin S Cooper Jr <fcooper@ti.com>,
        Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-can@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
        robh+dt@kernel.org, quentin.schulz@free-electrons.com,
        sergei.shtylyov@cogentembedded.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170728045724.GA27903@airbook.vandijck-laurijssen.be>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/28/2017 06:57 AM, Kurt Van Dijck wrote:

> So while _a_ transceiver may be spec'd to 1MBit during arbitration,
> CAN FD packets may IMHO exceed that speed during data phase.

When the bitrate is limited to 1Mbit/s you are ONLY allowed to use 
1Mbit/s in the data section too (either with CAN or CAN FD).

> That was the whole point of CAN FD: exceed the limits required for
> correct arbitration on transceiver & wire.

No. CAN FD is about a different frame format with up to 64 bytes AND the 
possibility to increase the bitrate in the data section of the frame.

> So I do not agree on the single bandwidth limitation.

The transceiver provides a single maximum bandwidth. It's an ISO Layer 1 
device.

> The word 'max-arbitration-bitrate' makes the difference very clear.

I think you are mixing up ISO layer 1 and ISO layer 2.

Regards,
Oliver

