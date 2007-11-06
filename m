From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter: nf_conntrack_ipv4 does not show nf_nat as a user
Date: Tue, 06 Nov 2007 01:12:18 +0100
Message-ID: <472FB162.7050507@trash.net>
References: <472F78C9.9060900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47900 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749AbXKFAMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 19:12:35 -0500
In-Reply-To: <472F78C9.9060900@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert wrote:
> https://bugzilla.redhat.com/show_bug.cgi?id=333481#c3
>
> This is netfilter kernel problem. There is a usage count for the conntrack_ipv4
> module from the nf_nat module, which is not reported by lsmod.
>   

This is "fixed" in the current kernel.
