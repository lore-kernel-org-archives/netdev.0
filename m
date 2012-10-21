From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 6/6] drivers: net: ethernet: cpsw: implement
 timestamping capabilities in cpsw
Date: Sun, 21 Oct 2012 20:11:42 +0200
Message-ID: <20121021181142.GA29044@netboy.at.omicron.at>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-7-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:47331 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932387Ab2JUSLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 14:11:52 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so1766679wib.1
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 11:11:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1350427518-7230-7-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 17, 2012 at 04:15:18AM +0530, Mugunthan V N wrote:
> This patch implements timestamping capabilities in cpsw through IOCTL interface
> to enable and disable PTP time stamping and adds hardware time stamps to the
> packet's skb buffer using cpts api

Just out of curiosity, I compiled and booted this patch series, but it
does not work. The CPTS driver fails with

   [ 1.901459] Missing cpts_reg_ofs property in the DT.
   [ 1.906835] cpsw: platform data missing

so I think you forgot to patch the dts files.

Thanks,
Richard
