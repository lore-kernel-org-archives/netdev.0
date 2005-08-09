From: "David S. Miller" <davem@davemloft.net>
Subject: Re: default directive in Kconfig(subject modified)
Date: Mon, 08 Aug 2005 19:38:16 -0700 (PDT)
Message-ID: <20050808.193816.70216612.davem@davemloft.net>
References: <002801c59c7a$fb660ec0$4810100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, raghavendra.koushik@neterion.com, jgarzik@pobox.com,
        netdev@oss.sgi.com, leonid.grossman@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@neterion.com
In-Reply-To: <002801c59c7a$fb660ec0$4810100a@pc.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

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
