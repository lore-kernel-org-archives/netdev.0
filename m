From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Tue, 12 Jul 2005 14:54:28 -0700
Message-ID: <000c01c5872c$47829c60$4f10100a@pc.s2io.com>
References: <20050712.140411.41107257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <hch@infradead.org>, <raghavendra.koushik@neterion.com>,
        <jgarzik@pobox.com>, <netdev@oss.sgi.com>,
        <leonid.grossman@neterion.com>, <rapuru.sriram@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@davemloft.net>
In-Reply-To: <20050712.140411.41107257.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Okay, got it. Will submit patch on Kconfig file after the macro
for SGI platforms is confirmed.

Ravi

-----Original Message-----
From: David S. Miller [mailto:davem@davemloft.net]
Sent: Tuesday, July 12, 2005 2:04 PM
To: ravinandan.arakali@neterion.com
Cc: hch@infradead.org; raghavendra.koushik@neterion.com;
jgarzik@pobox.com; netdev@oss.sgi.com; leonid.grossman@neterion.com;
rapuru.sriram@neterion.com
Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements


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
