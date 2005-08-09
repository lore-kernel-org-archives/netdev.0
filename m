From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: default directive in Kconfig(subject modified)
Date: Tue, 9 Aug 2005 14:26:05 -0700
Message-ID: <001001c59d28$f41c1160$4810100a@pc.s2io.com>
References: <20050808.193816.70216612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <hch@infradead.org>, <raghavendra.koushik@neterion.com>,
        <jgarzik@pobox.com>, <netdev@oss.sgi.com>,
        <leonid.grossman@neterion.com>, <rapuru.sriram@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@davemloft.net>
In-Reply-To: <20050808.193816.70216612.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yes, I got the run-time feature message. It will require quite
a bit of code reshuffle and testing to make sure we don't
break existing code in any way.

Thanks,
Ravi

-----Original Message-----
From: David S. Miller [mailto:davem@davemloft.net]
Sent: Monday, August 08, 2005 7:38 PM
To: ravinandan.arakali@neterion.com
Cc: hch@infradead.org; raghavendra.koushik@neterion.com;
jgarzik@pobox.com; netdev@oss.sgi.com; leonid.grossman@neterion.com;
rapuru.sriram@neterion.com
Subject: Re: default directive in Kconfig(subject modified)


From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Date: Mon, 8 Aug 2005 17:40:45 -0700

> Can somebody throw light on the below subject ?
> We have S2io configured as a module and 2buff mode is
> one of the suboptions under S2io. But a directive such
> as "default y" does not seem to enable 2buff mode.

Independant of this issue, can you please acknowledge what
many people are trying to show you in that you MUST make
this a run-time selectable feature.

Yes, that means the driver will have to have two totally
seperate code paths.  But that should not be inefficient
because you can just hook up different transmit and
interrupt handler methods depending upon the mode selected.
