From: Micha Nelissen <micha@neli.hopto.org>
Subject: Re: Commit "ipconfig wait for carrier" makes boot hang for 2 mins
 if no carrier
Date: Tue, 04 Sep 2012 18:09:08 +0200
Message-ID: <504627A4.9080306@neli.hopto.org>
References: <OF61EF9E6E.9EF08C21-ONC1257A6F.004FE9B4-C1257A6F.0050A9B2@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isp-bos-02.edutel.nl ([88.159.1.183]:45877 "EHLO
	isp-bos-02.edutel.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777Ab2IDQTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 12:19:17 -0400
In-Reply-To: <OF61EF9E6E.9EF08C21-ONC1257A6F.004FE9B4-C1257A6F.0050A9B2@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Op 2012-09-04 16:41, Joakim Tjernlund schreef:
> Above mentioned commit(3fb72f1e6e6165c5f495e8dc11c5bbd14c73385c) changes
> a ~1 sec delay to ~120 sec boot delay if no carrier. This is a really
> long time to wait if you just want to set an IP address but doesn't
> care about NFS root, holds up the boot with 2 minutes.

Why not set the IP address then in your rootfs yourself?

Micha
