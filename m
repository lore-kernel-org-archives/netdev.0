From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] micrel: fix masking off LED bits
Date: Wed, 19 Mar 2014 09:12:33 +0100
Message-ID: <53295171.3020700@codethink.co.uk>
References: <201403190258.16812.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201403190258.16812.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/03/14 00:58, Sergei Shtylyov wrote:
> Commit 20d8435a1cff (phy: micrel: add of configuration for LED mode) made the
> obvious mistake when masking off  the LED mode bits: forgot to do a logical NOT
> to the mask with which it ANDs the register value, so that unrelated bits are
> cleared instead.
>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Acked-by: Ben Dooks <ben.dooks@codethink.co.uk>

Oops, thanks for noticing that.

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
