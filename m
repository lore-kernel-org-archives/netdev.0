From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next repost v2 2/3] ptp: Classify ptp over ip over
 vlan packets
Date: Sat, 5 Jul 2014 20:58:46 +0200
Message-ID: <20140705185846.GA3869@localhost.localdomain>
References: <1404312104-19154-1-git-send-email-stefan.sorensen@spectralink.com>
 <1404312104-19154-3-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:62935 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754882AbaGES7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 14:59:10 -0400
Received: by mail-wi0-f173.google.com with SMTP id cc10so14101423wib.12
        for <netdev@vger.kernel.org>; Sat, 05 Jul 2014 11:59:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1404312104-19154-3-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 02, 2014 at 04:41:43PM +0200, Stefan S=F8rensen wrote:
> This extends the ptp bpf to also match ptp over ip over vlan packets.=
 The ptp
> classes are changed to orthogonal bitfields representing version, tra=
nsport
> and vlan values to simplify matching.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>

I like the simplied matching routines, and I also checked the BPF_ASM
program. Thanks for this patch series.

Acked-by: Richard Cochran <richardcochran@gmail.com>
