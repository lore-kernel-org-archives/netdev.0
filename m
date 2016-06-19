From: David Ranch <linux-hams@trinnet.net>
Subject: Re: PATCH 1/1] AX.25: Close socket connection on session completion
Date: Sat, 18 Jun 2016 18:44:32 -0600
Message-ID: <1823727F-73BC-4E1C-8F3E-23C4FA547BB7@trinnet.net>
References: <20160616094230.1d023d0b@brox.localnet> <20160617.113319.2120711643214980498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: jreuter@yaina.de, ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, basil@pacabunga.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20160617.113319.2120711643214980498.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

I don't have a specific commit # for you at the moment but there have been a few serious regressions since 4.1.x.  When new code gets commited, are there any systems to run regession tests on?  I'd be willing to build up a pair of VMs that can be run with scripts to verify say basic sanity for kissattach, ax.25, netrom, rose, etc.

Btw, once I get back, I hope to pursue some additional negative case fixes:  (pulling a usb-to-serial adapter when used with kiss-attach will panic the kernel, ifconfig rose0 down will take the kernel to 100%, and a data corruption issue for large transfers (2MB+).

Thanks for your help!

--David
KI6ZHD
--David

On June 17, 2016 12:33:19 PM CST, David Miller <davem@davemloft.net> wrote:
>From: Basil Gunn <basil@pacabunga.com>
>Date: Thu, 16 Jun 2016 09:42:30 -0700
>
>> A socket connection made in ax.25 is not closed when session is
>> completed.  The heartbeat timer is stopped prematurely and this is
>> where the socket gets closed. Allow heatbeat timer to run to close
>> socket. Symptom occurs in kernels >= 4.2.0
>> 
>> Originally sent 6/15/2016. Resend with distribution list matching
>> scripts/maintainer.pl output.
>> 
>> Signed-off-by: Basil Gunn <basil@pacabunga.com>
>
>What changed in 4.2.x that broke this?
>--
>To unsubscribe from this list: send the line "unsubscribe linux-hams"
>in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

