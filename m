From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 1/1] r8169: default on disabling PCIDAC
Date: Mon, 20 Sep 2004 14:14:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414F1DFD.9030008@pobox.com>
References: <20040919224102.GA32577@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hans-Frieder Vogt <hfvogt@arcor.de>, Andy Lutomirski <luto@myrealbox.com>,
        Jon Mason <jdmason@us.ibm.com>,
        Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040919224102.GA32577@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Default to disabling PCI DAC as this option appears unsafe on amd64
> (original suggestion by Hans-Frieder Vogt <hfvogt@arcor.de>).
> 
> The driver will typically report PCI System error when something goes
> wrong. The relevant interrupt is not masked any more and the driver
> can thus be disabled.


Can this interrupt be used at runtime to detect that DAC isn't working?

	Jeff
