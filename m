From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: e100/netconsole: Failed to load firmware (Re: linux-next: Tree for November 3)
Date: Mon, 3 Nov 2008 15:25:07 +0300
Message-ID: <a4423d670811030425y1bdf93fcn829b7311e38731b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: e1000-devel@lists.sourceforge.net
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

2.6.28-rc3-next-20081103 on sparc64

netconsole on e100 does not work

pci 0000:02:01.0: supports D1 D2
pci 0000:02:01.0: PME# supported from D0 D1 D2 D3hot
pci 0000:02:01.0: PME# disabled
device: '0000:02:01.0': device_add
bus: 'pci': add device 0000:02:01.0
pci 0000:02:01.0: calling quirk_e100_interrupt+0x0/0x1e4
pci 0000:02:01.0: calling quirk_cardbus_legacy+0x0/0x40
pci 0000:02:01.0: calling quirk_usb_early_handoff+0x0/0x42c
<...>
e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
bus: 'pci': add driver e100
bus: 'pci': driver_probe_device: matched device 0000:02:01.0 with driver e100
bus: 'pci': really_probe: probing driver e100 with device 0000:02:01.0
PCI: Enabling device: (0000:02:01.0), cmd 3
e100 0000:02:01.0: enabling bus mastering
e100 0000:02:01.0: PME# disabled
device: 'eth1': device_add
e100: eth1: e100_probe: addr 0x1ff00002000, irq 15, MAC addr 00:d0:b7:e4:d6:f1
driver: '0000:02:01.0': driver_bound: bound to device 'e100'
bus: 'pci': really_probe: bound device 0000:02:01.0 to driver e100
netconsole: local port 6665
netconsole: local IP 192.168.1.5
netconsole: interface eth1
netconsole: remote port 6667
netconsole: remote IP 192.168.1.3
netconsole: remote ethernet address 00:08:c7:da:88:fb
netconsole: device eth1 not up yet, forcing it
e100 0000:02:01.0: firmware: requesting e100/d101m_ucode.bin
device: '0000:02:01.0': device_add
device: '0000:02:01.0': device_unregister
e100: eth1: e100_request_firmware: Failed to load firmware
"e100/d101m_ucode.bin": -2
netconsole: failed to open eth1
netconsole: cleaning up
<...>
e100 0000:02:01.0: firmware: requesting e100/d101m_ucode.bin
device: '0000:02:01.0': device_add
device: '0000:02:01.0': device_unregister
e100: eth1: e100_watchdog: link up, 100Mbps, full-duplex


netconsole output (less verbose) from 2.6.28-rc3:

e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
e100 0000:02:01.0: PME# disabled
e100: eth1: e100_probe: addr 0x1ff00002000, irq 15, MAC addr 00:d0:b7:e4:d6:f1
netconsole: local port 6665
netconsole: local IP 192.168.1.5
netconsole: interface eth1
netconsole: remote port 6667
netconsole: remote IP 192.168.1.3
netconsole: remote ethernet address 00:08:c7:da:88:fb
netconsole: device eth1 not up yet, forcing it
e100: eth1: e100_watchdog: link up, 100Mbps, full-duplex
netconsole: carrier detect appears untrustworthy, waiting 4 seconds
console [netcon0] enabled
netconsole: network logging started
