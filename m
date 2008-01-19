From: Paul Moore <paul.moore@hp.com>
Subject: Re: Memory leak in security_netlbl_sid_to_secattr(), kernel 2.6.23.12
Date: Fri, 18 Jan 2008 22:35:30 -0500
Message-ID: <200801182235.31189.paul.moore@hp.com>
References: <47913417.3090504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:4931 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757143AbYASDfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 22:35:42 -0500
In-Reply-To: <47913417.3090504@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 18 January 2008 6:19:51 pm Chuck Ebbert wrote:
> We have two reports of this now.
>
> https://bugzilla.redhat.com/show_bug.cgi?id=352281
>
> The user enabled SLUB user tracing and reports that the entries
> created by security_netlbl_sid_to_secattr() were increasing the
> most.  Disabling selinux makes the problem go away completely.

Thanks for the report, sorry about the leak.  I just posted an RFC patch, CC'd 
to you, which I believe should fix the problem.  I did a quick compile test 
on the SELinux module but I am "on vacation" with family visiting so I am 
currently unable to do any real testing until next week.

I've added myself to the bugzilla, but if you are able to do any tests please 
let me know if the patch does or does not solve the problem.

Thanks.

-- 
paul moore
linux security @ hp
