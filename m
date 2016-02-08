From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] af_unix: Don't set err in unix_stream_read_generic unless
 there was an error
Date: Mon, 8 Feb 2016 21:33:38 +0300
Message-ID: <56B8DF82.9070104@cogentembedded.com>
References: <56B4EF04.2060407@canonical.com>
 <87zivebxjr.fsf@doppelsaurus.mobileactivedefense.com>
 <87lh6wl44b.fsf@doppelsaurus.mobileactivedefense.com>
 <87bn7rtdwe.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, edumazet@google.com,
	dhowells@redhat.com, ying.xue@windriver.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Joseph Salisbury <joseph.salisbury@canonical.com>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87bn7rtdwe.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/08/2016 06:33 PM, Rainer Weikusat wrote:

> The present unix_stream_read_generic contains various code sequences of
> the form
>
> err = -EDISASTER;
> if (<test>)
> 	goto out;
>
> This has the unfortunate side effect of possibly causing the error code
> to bleed through to the final
>
> out:
> 	return copied ? : err;
>
> and then to be wrongly returned if no data was copied because the caller
> didn't supply a data buffer, as demonstrated by the program available at
>
> http://pad.lv/1540731
>
> Change it such that err is only set if an error condition was detected.
>
> Fixes: 3822b5c2fc62

    You also need to specify the patch summary like this: ("<summary").

> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
[...]

MBR, Sergei
