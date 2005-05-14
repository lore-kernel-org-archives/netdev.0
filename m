From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: SCTP: use lib/libcrc32c.c instead of net/sctp/crc32c.c?
Date: Fri, 13 May 2005 18:01:27 -0700
Message-ID: <42854DE7.5030704@us.ibm.com>
References: <20050513135004.GG3603@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Clay Haapala <chaapala@cisco.com>,
	lksctp-developers@lists.sourceforge.net, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262646AbVENBBd@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050513135004.GG3603@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:

>As far as I understand it, lib/libcrc32c.c could be used instead of the 
>similar code in net/sctp/crc32c.c .
>
>Is there any reason why this isn't done?
>  
>
The SCTP RFC3309 says that SCTP uses a tranport-level CRC where the bit
ordering is mirrored and different from link-level CRC.

The CRC is computed using a procedure similar to ETHERNET CRC [ITU32],
modified to reflect transport level usage.

So I am not sure if we can use the libcrc32c routines for calculating SCTP
crc32 checksum. But if it is possible, we should definitely use the crc32
library.

Thanks
Sridhar
