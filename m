From: "Andrew Paprocki" <andrew@ishiboo.com>
Subject: Re: [PATCH] ethtool: Add register dump support for all r8169 driver cards
Date: Wed, 26 Mar 2008 18:11:02 -0400
Message-ID: <76366b180803261511x518e4475n72dbcee2d1942be3@mail.gmail.com>
References: <76366b180803260519t7c446210n62d4c91209c5e971@mail.gmail.com>
	 <20080326214432.GA9356@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jeff Garzik" <jeff@garzik.org>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:5661 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669AbYCZWLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 18:11:03 -0400
Received: by wf-out-1314.google.com with SMTP id 28so3525389wff.4
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 15:11:02 -0700 (PDT)
In-Reply-To: <20080326214432.GA9356@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2008 at 5:44 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
>  Please revert: this register is reserved in the 8168.
>
>  PHY access and PHY status are ok for the 8168. TBI and PM registers are not.
>
>  The 8168 should not be included here.

I'll update this shortly and re-send again. Do you have 8168 docs
showing the differences between it and the 8169? I peeked at this code
because I'm trying to track down a 8110SC problem where the network
hangs (sender hangs on sk_stream_wait_memory). Any useful docs on
these chips would help. Thanks, -Andrew
