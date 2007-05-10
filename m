From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Enable netem in my Linux box
Date: Thu, 10 May 2007 08:42:32 -0700
Message-ID: <20070510084232.147e1d8f@freepuppy>
References: <4641E945.3070902@lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Yick, Koon Wah (Koon)" <kyick@homail.ho.lucent.com>
To: Koon Wah Yick <kyick@alcatel-lucent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36069 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757450AbXEJPmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 11:42:43 -0400
In-Reply-To: <4641E945.3070902@lucent.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 09 May 2007 11:31:17 -0400
Koon Wah Yick <kyick@alcatel-lucent.com> wrote:

> Hi:
> 
> My Linux box has CentOS5 installed.  But I could not run tc command with any
> netem parameters in command line. as shown in web site
> http://linux-net.osdl.org/index.php/Netem.  I suspect, Netem was either not part
> of the installed OS or has not been enabled.  Can you tell how to verified?
> When I type in "rpm -qa" I see only iproute-2.6.18-4.el5, do I need iproute2?
> Can you tell me how to update my Linux kernel to include netem functionality.
> Thanks,
> 
> Koon-Wah.
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

modinfo sch_netem

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
