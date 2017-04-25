From: Waldemar Rymarkiewicz <waldemar.rymarkiewicz@gmail.com>
Subject: Network cooling device and how to control NIC speed on thermal condition
Date: Tue, 25 Apr 2017 10:36:28 +0200
Message-ID: <CAHKzcEMQPQzg6PYCSuv7Ufad+4AZ2gnqMgz3-VH5NTeb_pv4zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am not much aware of linux networking architecture so I'd like to
ask first before will start to dig into the code. Appreciate any
feedback.

I am looking on Linux thermal framework and on how to cool down the
system effectively when it hits thermal condition. Already existing
cooling methods cpu_cooling and clock_cooling are good. However, I
wanted to go further and dynamically control also a switch ports'
speed based on thermal condition. Lowering speed means less power,
less power means lower temp.

Is there any in-kernel interface to configure switch port/NIC from other driver?

Is there any mechanism to power save, when port/interface is not
really used (not much or low data traffic), embedded in networking
stack  or is it a task for NIC driver itself ?

I was thinking to create net_cooling device similarly to cpu_cooling
device which cool down the system scaling down cpu freq.  net_cooling
could lower down interface speed (or tune more parameters to achieve
).  Do you thing could this work form networking stack perspective?

Any pointers  to the code or a doc highly appreciated.

Thanks,
/Waldek
