From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: DoS by cat /proc/net/ip_conntrack ?
Date: Sat, 8 Mar 2008 15:44:26 +0100
Message-ID: <20080308144426.GB3378@ami.dom.local>
References: <20080306134037.M70019@visp.net.lb> <Pine.LNX.4.64.0803061449220.23263@bizon.gios.gov.pl> <47D28601.4080106@gmail.com> <47D28786.80600@gmail.com> <20080308142254.M64724@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:64190 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbYCHOhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 09:37:25 -0500
Received: by ug-out-1314.google.com with SMTP id z38so4593402ugc.16
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2008 06:37:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080308142254.M64724@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 08, 2008 at 04:24:34PM +0200, Denys Fedoryshchenko wrote:
> For me personally, i think must be as a rule, that _READING_ must not hang 
> whole system by consuming all resources (router becoming completely 
> unreachable and blocking all traffic passing thru it). It can hang console, 
> current program, but not crash router.

IMHO you're right, and it's a bug. Only calling this DOS isn't probably
very right if only root can do this, but maybe I'm wrong.

Jarek P.
