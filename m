From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] NET: AX88796: Tighten up Kconfig dependencies
Date: Mon, 27 Jun 2011 18:38:44 -0700 (PDT)
Message-ID: <20110627.183844.146129637361136342.davem@davemloft.net>
References: <20110627111259.GA13620@linux-mips.org>
        <BANLkTikDxsOJKpiJs0NpMXbjVOFMHL7RZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, eric.y.miao@gmail.com, linux@arm.linux.org.uk,
        ben-linux@fluff.org, lethal@linux-sh.org, jeff@garzik.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linux-sh@vger.kernel.org, netdev@vger.kernel.org,
        linux-mips@linux-mips.org
To: magnus.damm@gmail.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <BANLkTikDxsOJKpiJs0NpMXbjVOFMHL7RZw@mail.gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: Magnus Damm <magnus.damm@gmail.com>
Date: Tue, 28 Jun 2011 09:40:56 +0900

> As for SH and SH-Mobile ARM, unless explicitly requested we usually
> don't restrict our platform drivers. Allowing them to build on any
> system helps to catch compile errors.

I totally agree with Magnus, drivers should build on as many systems
as possible.  Even on those for which the hardware never appears.

Ralf, unless these drivers have unfixable build errors on MIPS I
do not want to add the new restrictions.
