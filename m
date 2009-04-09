From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13004] New: [bonding] xmit hash policy doesn't
 recognize vlan tagged and PPPoE frames
Date: Thu, 9 Apr 2009 14:10:00 -0700
Message-ID: <20090409141000.d0ae7fcb.akpm@linux-foundation.org>
References: <bug-13004-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, adwol@zonk.pl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33707 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756079AbZDIVNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 17:13:34 -0400
In-Reply-To: <bug-13004-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 3 Apr 2009 16:34:24 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13004
> 
>            Summary: [bonding] xmit hash policy doesn't recognize vlan
>                     tagged and PPPoE frames
>            Product: Networking
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: adwol@zonk.pl
>         Regression: No
> 
> 
> Hi,
> 
> there is a problem with xmit hash policy in bonding driver. It doesn't work
> when using layer 2+3 or 3+4 policy on vlan tagged or PPPoE frames.
> Functions bond_xmit_hash_policy_l23() and bond_xmit_hash_policy_l34()
> check if frame ethertype is ETH_P_IP and unless, it fall back to layer 2
> hashing. It additionally should check, if frame ethertype is ETH_P_8021Q or
> ETH_P_PPP_SES and embedded type is ETH_P_IP and if so, also treat it as
> IP packet.
> 
> Appropriate patch in attachment.
> 

Jay, there's a patch in there.

Adam, please prefer to submit patches via email as per
Documentation/SubmittingPatches rather than via bugzilla, thanks.

