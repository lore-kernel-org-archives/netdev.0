From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: 2.6.16.11 BUG at tg3.c:2917
Date: Thu, 27 Apr 2006 08:45:24 -0700
Message-ID: <1146152724.11406.3.camel@rh4>
References: <20060427165234.GC29045@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2833 "EHLO mms1.broadcom.com")
	by vger.kernel.org with ESMTP id S965165AbWD0RZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 13:25:27 -0400
To: "Ed L. Cashin" <ecashin@coraid.com>
In-Reply-To: <20060427165234.GC29045@coraid.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-04-27 at 12:52 -0400, Ed L. Cashin wrote:
> -- [please bite here ] ---------
> Kernel BUG at drivers/net/tg3.c:2917
> invalid opcode: 0000 [1] SMP 
> CPU 0 

Most likely caused by IO re-ordering. Try the test patch in this
discussion:

http://marc.theaimsgroup.com/?l=linux-netdev&m=113890239404768&w=2

