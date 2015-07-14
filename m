From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH v3 0/3] net: enable inband link state negotiation only when
 explicitly requested
Date: Tue, 14 Jul 2015 20:09:33 +0300
Message-ID: <55A5424D.4030809@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Currently the link status auto-negotiation is enabled
for any SGMII link with fixed-link DT binding.
The regression was reported:
https://lkml.org/lkml/2015/7/8/865
Apparently not all HW that implements SGMII protocol, generates the
inband status for the auto-negotiation to work.
More details here:
https://lkml.org/lkml/2015/7/10/206

The following patches reverts to the old behavior by default,
which is to not enable the auto-negotiation for fixed-link.
The new DT property is added that allows to explicitly request
the auto-negotiation.

Those who were affected by the change, please send your Tested-by,
Thanks!
