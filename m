From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: CAN-FD Transceiver Limitations
Date: Wed, 28 Jun 2017 17:14:42 -0500
Message-ID: <de1f6343-4b28-4a5f-c6df-4e54c09fcce2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

The various CAN transceivers I've seen that support CAN-FD appear to be
fairly limited in terms of their supported max speed. I've seen some
transceivers that only support upto 2 Mbps while others support up to  5
Mbps. This is a problem when the SoC's CAN IP can support even higher
values than the transceiver.

Ideally I would think the MCAN driver should at the very least know what
the maximum speed supported by the transceiver it is connected to.
Therefore, either throwing an error if a request for a speed above the
transceiver capability or lower the requested speed to what ever the
transceiver is capability of doing.

In either case I do not know if it makes sense to add a DT property
within the MCAN driver or create another subnode that contains this
information. For example I see some ethernet drivers support
"fixed-link" subnode which is trying to solve a similar issue. Should I
go with that approach? If so would it make sense to reuse fixed-link
even though majority of its properties aren't applicable? Or should I
create something similar such as fixed-can-transceiver?
