From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10611] New: Incorrect RFC section reference in
 comment
Date: Tue, 6 May 2008 23:33:51 -0700
Message-ID: <20080506233351.1fe19fe6.akpm@linux-foundation.org>
References: <bug-10611-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: jdassen@debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44375 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752380AbYEGGeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 02:34:09 -0400
In-Reply-To: <bug-10611-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue,  6 May 2008 23:25:14 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10611
> 
>            Summary: Incorrect RFC section reference in comment
>            Product: Networking
>            Version: 2.5
>      KernelVersion: master branch
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: jdassen@debian.org
> 
> 
> Problem Description:
> 
> RFC 1122 does not have a section 3.1.2.2. The requirement to silently
> discard packets with a bad checksum is in section 3.2.1.2 instead.
> 
> Proposed patch:
> 
> diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
> index 212734c..5bdb8f4 100644
> --- a/net/ipv4/ip_input.c
> +++ b/net/ipv4/ip_input.c
> @@ -394,7 +394,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev,
> struct packet_type *pt,
>         iph = skb->nh.iph;
> 
>         /*
> -        *      RFC1122: 3.1.2.2 MUST silently discard any IP frame that fails
> the checksum.
> +        *      RFC1122: 3.2.1.2 MUST silently discard any IP frame that fails
> the checksum.
>          *
>          *      Is the datagram acceptable?
>          *
> 
> 

Thanks, but we much prefer that patches be handled via email.  Can you
please resend the patch as a reply-to-all to this email, along with a
signed-off-by: as per Documentation/SubmittingPatches?
