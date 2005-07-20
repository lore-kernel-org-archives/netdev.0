From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: Seeing problem on 2.6.13-rc3
Date: Wed, 20 Jul 2005 10:04:36 -0700
Message-ID: <001201c58d4d$1c1f78f0$4f10100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Leonid. Grossman \(E-mail\)" <leonid.grossman@neterion.com>,
        "Raghavendra. Koushik \(E-mail\)" <raghavendra.koushik@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I am facing the following problem with loading S2io 10GbE driver on 
2.6.13-rc3.
Just wondering if anybody else is having similar problems with S2io
driver or other drivers.

When trying to load s2io driver, I see the following message:

eth%d: 1:Endian settings are wrong, feedback read ffffffffffffffff
eth%d:swapper settings are wrong

Basically, we try to configure the card for correct access on
both endian systems. This seems to fail.
But on a somewhat similar kernel(2.6.13-rc2-mm2), with the same
system, card and driver, it works fine.

Thanks,
Ravi
