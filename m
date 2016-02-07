From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH v2] net: ethernet: davicom: fix devicetree irq resource
Date: Sun, 07 Feb 2016 12:47:18 +0100
Message-ID: <87pow83fp5.fsf@belgarion.home>
References: <1454796693-4446-1-git-send-email-robert.jarzmik@free.fr>
	<56B72133.5090801@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B72133.5090801@cogentembedded.com> (Sergei Shtylyov's message
	of "Sun, 7 Feb 2016 13:49:23 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:

>> Moreover, since commit Fixes: 7085a7401ba5 ("drivers: platform: parse
>
>    Fixes: tag here?
Heuh no. It doesn't fix this commit, it uses a feature brought by this commit.

>> +	if (irq_get_trigger_type(dev->irq) == IRQF_TRIGGER_NONE)
>>   		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
>>
>>   	irqflags |= IRQF_SHARED;
>
>    Why not just initialize to IRQF_SHARED?
>    But actually you don't need this variable anymore.
Yeah, makes sense.

Cheers.

-- 
Robert
