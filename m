From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Fw: [Bugme-new] [Bug 6401] New: tg3 hardware address issue
Date: Mon, 17 Apr 2006 13:21:44 -0700
Message-ID: <1145305304.3677.4.camel@rh4>
References: <20060417141715.30afbdd8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zef@cektek.net,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:31500 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751324AbWDQWCD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 18:02:03 -0400
To: "Andrew Morton" <akpm@osdl.org>
In-Reply-To: <20060417141715.30afbdd8.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-17 at 14:17 -0700, Andrew Morton wrote:

> Right now I am using the tg3.c contained in linus's git tree with a 2.6.15 
> kernel because this driver version (3.56) seems to be least broken, or atleast 
> hides it best.

The reason it hides it best is because the is_valid_ether_addr() is
somewhat broken in 2.6.15. tg3 continues to load despite the invalid MAC
address of ff:ff:ff:ff:ff:ff.

Please send the output of lspci -vvvxxx -s0:3:0.0 and lspci -vvvxxx -
s0:4:0.0. Thanks.


