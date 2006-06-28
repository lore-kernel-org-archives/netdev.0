From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [2.6 patch] net/dccp/: possible cleanups
Date: Thu, 29 Jun 2006 06:11:45 +1200
Message-ID: <5640c7e00606281111y2b4e6d4at611d0195847377cc@mail.gmail.com>
References: <20060628165430.GM13915@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: acme@mandriva.com, dccp@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750743AbWF1SLr@vger.kernel.org>
To: "Adrian Bunk" <bunk@stusta.de>
In-Reply-To: <20060628165430.GM13915@stusta.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Comments below:

On 6/29/06, Adrian Bunk <bunk@stusta.de> wrote:
> This patch contains the following possible cleanups:
> - sysctl.c: the Kconfig rules already disallow CONFIG_SYSCTL=n,
>             there's no need for an additional check
Agree

> - proper extern declarations for some variables in dccp.h
NAK - have sent another patch to shift these to feat.h. Arnaldo is
reviewing patches next week.

> - make the following needlessly global function static:
>   - ipv4.c: dccp_v4_checksum()
Agree

> - #if 0 the following unused functions:
>   - ackvec.c: dccp_ackvector_print()
>   - ackvec.c: dccp_ackvec_print()
>   - output.c: dccp_send_delayed_ack()

NAK on the first two. These are for debugging and DCCP still needs
improving so I think worthwhile having there in short term so we can
quickly call them if needed.

I will leave Arnaldo or Andrea to comment on last one...

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
