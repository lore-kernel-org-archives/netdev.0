From: <Mario.Limonciello@dell.com>
Subject: RE: [PATCH v8 3/8] thunderbolt: Communication with the ICM (firmware)
Date: Mon, 19 Dec 2016 17:21:39 +0000
Message-ID: <05d9c1db67af410981bbb9672071a237@ausx13mpc120.AMER.DELL.COM>
References: <1475073870-2126-1-git-send-email-amir.jer.levy@intel.com>
 <1475073870-2126-4-git-send-email-amir.jer.levy@intel.com>
 <fe0f0a6f-488b-bbc0-8987-a9c47d9ed9b9@kernel.org>
 <20161219122407.GQ1460@lahna.fi.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: <amir.jer.levy@intel.com>, <gregkh@linuxfoundation.org>,
        <andreas.noever@gmail.com>, <bhelgaas@google.com>,
        <corbet@lwn.net>, <linux-kernel@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-doc@vger.kernel.org>, <thunderbolt-linux@intel.com>,
        <tomas.winkler@intel.com>, <xiong.y.zhang@intel.com>
To: <mika.westerberg@intel.com>, <luto@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161219122407.GQ1460@lahna.fi.intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dell - Internal Use - Confidential =20

>=20
> There is small problem, though. On non-Apple systems the host controller =
only
> appears when something is connected to thunderbolt ports. So the char dev=
ice
> would not be there all the time. However, I think we can still notify the
> userspace by sending an extra uevent when we detect there is a PCIe devic=
e or
> inter-domain connection plugged in.
>=20

Why couldn't you just create it the first time a device is plugged into a T=
hunderbolt
port and leave it until the module is cleaned up?  If the host controller g=
oes to sleep
an event could be sent to the daemon to let it know it disappeared and not =
to expect
data on the char device for now, but leave the node around.=20
