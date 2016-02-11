From: Justin Keller <justincompsci@gmail.com>
Subject: possible patch
Date: Wed, 10 Feb 2016 19:49:11 -0500
Message-ID: <CALah4Nc5Bx6FYfSnQWNaSd3YpurhKU1viqZx1KdU_M6sO0cG2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-kernel@vger.kernel.org, isdn@linux-pingi.de,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
I am new to submitting patches, so sorry if I am doing it wrong. My idea was
to change line 147 in drivers/isdn/pcbit/callbacks.c from
if (cbdata->data.setup.CallingPN == NULL) {

to

if (cbdata->data.setup.CallingPN == NULL ||
sizeof(cbdata->data.setup.CallingPN)>sizeof(ictl.parm.setup.phone) {

Justin Keller
