From: Komuro <komurojun-mbn@nifty.com>
Subject: Re: [BUG KERNEL 2.6.20-rc1]  ftp: get or put stops during
 file-transfer
Date: Sat, 30 Dec 2006 18:50:43 +0900
Message-ID: <20061230185043.d31d2104.komurojun-mbn@nifty.com>
References: <20061217212752.d93816b4.komurojun-mbn@nifty.com>
	<20061217040222.GD17561@ftp.linux.org.uk>
	<20061217232311.f181302f.komurojun-mbn@nifty.com>
	<20061218030113.GT10316@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, Al Viro <viro@ftp.linux.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg501.nifty.com ([202.248.238.81]:41368 "EHLO
	userg501.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755126AbWL3Av2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Dec 2006 19:51:28 -0500
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061218030113.GT10316@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I investigated the ftp-file-transfer-stop problem by git-bisect method,
and found this problem was introduced by
"[TCP]: MD5 Signature Option (RFC2385) support" patch.

Mr.YOSHIFUJI san, please fix this problem.

>commit cfb6eeb4c860592edd123fdea908d23c6ad1c7dc
>Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>Date:   Tue Nov 14 19:07:45 2006 -0800
>
>    [TCP]: MD5 Signature Option (RFC2385) support.
>    
>    Based on implementation by Rick Payne.
>    
>    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>    Signed-off-by: David S. Miller <davem@davemloft.net>

Best Regards
Komuro


> On Sun, Dec 17, 2006 at 11:23:11PM +0900, Komuro wrote:
> > On Sun, 17 Dec 2006 04:02:22 +0000
> > Al Viro <viro@ftp.linux.org.uk> wrote:
> > 
> > > On Sun, Dec 17, 2006 at 09:27:52PM +0900, Komuro wrote:
> > > > 
> > > > Hello,
> > > > 
> > > > On kernel 2.6.20-rc1, ftp (get or put) stops
> > > > during file-transfer.
> > > > 
> > > > Client: ftp-0.17-33.fc6  (192.168.1.1)
> > > > Server: vsftpd-2.0.5-8   (192.168.1.3)
> > > > 
> > > > This problem does _not_ happen on kernel-2.6.19.
> > > > is it caused by network-subsystem change on 2.6.20-rc1??
> > > 
> > > Do you have NAT between you and server?
> > 
> > No. I don't have NAT between the client and the server.
> > Actually, the client and the sever is located in same room.
> > 
> > client -- 100MbpsHub -- server.

