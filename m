From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Fri, 29 Jul 2005 09:37:55 -0700
Message-ID: <001001c5945b$df8afd90$4810100a@pc.s2io.com>
References: <20050712.140411.41107257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
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

David,
We are trying to use the "default" directive in Kconfig. We tried
using an unconditional directive(just to test it out) such as
"default y" and a conditional one such as "default y if
CONFIG_IA64_SGI_SN2".

But when we run "make menuconfig", it does not seem to pickup any of these
changes from Kconfig.
Any idea what we might be missing ?

Once this is fixed, we'll send out a patch to address comments from
previous 12 patches as well as couple of issues we found in the
meantime.

Thanks,
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
