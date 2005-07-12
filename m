From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Tue, 12 Jul 2005 14:04:11 -0700 (PDT)
Message-ID: <20050712.140411.41107257.davem@davemloft.net>
References: <20050712.133404.52118192.davem@davemloft.net>
	<000a01c58724$ca41a7c0$4f10100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, raghavendra.koushik@neterion.com, jgarzik@pobox.com,
        netdev@oss.sgi.com, leonid.grossman@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@neterion.com
In-Reply-To: <000a01c58724$ca41a7c0$4f10100a@pc.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Tue, 12 Jul 2005 14:00:52 -0700

> The two-buffer mode was added as a configurable option
> to Kconfig file several months ago. Hence the macro
> is CONFIG_2BUFF_MODE.

We're saying that you should choose CONFIG_2BUFF_MODE, when
CONFIG_IA64_SGI_SN2 is set, inside the Kconfig file using the
"default" Kconfig directive.

You should never change the setting of CONFIG_* macros in C source.
