From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario which now
 beyond the range time_after_eq().
Date: Thu, 24 Oct 2013 19:34:42 +0800
Message-ID: <526905D2.4000003@oracle.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com> <525FBB4F02000078000FBB30@nat28.tlf.novell.com> <525FA79F.8060601@oracle.com> <525FC98002000078000FBBB5@nat28.tlf.novell.com> <52601274.5010008@oracle.com> <526102DE02000078000FBFBB@nat28.tlf.novell.com> <5260EDD8.4020608@oracle.com> <52610CD202000078000FC00B@nat28.tlf.novell.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7396@saturn3.aculab.com> <20131018112417.GA20185@zion.uk.xensource.com> <52678286.6000802@oracle.com> <5268025002000078000A56B5@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: david.vrabel@citrix.com, ian.campbell@citrix.com,
	xen-devel@lists.xenproject.org, annie.li@oracle.com,
	netdev@vger.kernel.org
To: Jan Beulich <jbeulich@suse.com>, David.Laight@ACULAB.COM,
	wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30732 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844Ab3JXLfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 07:35:02 -0400
In-Reply-To: <5268025002000078000A56B5@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>> As I understand it, this is the idea of this patch -- to narrow down the
>>> timing window.
>> Jan,  do you agree the idea or have better suggestion to me.
> As said before - I disagree (reducing a timing window is never a solution,
> only eliminating it is), and I pointed at the alternative (using 64-bit
> calculations) before.
Your mean is that add u64 member into struct xenvif or add static 
variable to keep expire?

Jason
>
> Jan
>
