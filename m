From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 16:46:01 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40A28D09.2080006@pobox.com>
References: <15FDCE057B48784C80836803AE3598D50627ACD5@racerx.ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: 'Andrew Morton' <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>,
	davidel@xmailserver.org, greg@kroah.com,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S263756AbUELUsJ@vger.kernel.org>
To: Jan Olderdissen <jan@ixiacom.com>
In-Reply-To: <15FDCE057B48784C80836803AE3598D50627ACD5@racerx.ixiacom.com>
List-Id: netdev.vger.kernel.org

Jan Olderdissen wrote:
> Couple nitpicks:
> 
> 
>>#if HZ=1000
> 
> 
> #if HZ==1000
> 
> 
>>#define	MSEC_TO_JIFFIES(msec) (msec)
>>#define JIFFIES_TO_MESC(jiffies) (jiffies)
>>#elif HZ=100
> 
> 
> #elif HZ==100
> 
> 
>>#define	MSEC_TO_JIFFIES(msec) (msec * 10)
>>#define JIFFIES_TO_MESC(jiffies) (jiffies / 10)
> 
> 
> #define JIFFIES_TO_MSEC(jiffies) (jiffies / 10)
> 
> 
>>#else
>>#define	MSEC_TO_JIFFIES(msec) ((HZ * (msec) + 999) / 1000)
>>#define	JIFFIES_TO_MSEC(jiffies) ...
>>#endif


And let's use something other than the name of a global variable in the 
macros...  it hurts my brain, at least...  :)

	Jeff
