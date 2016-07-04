From: David Ranch <linux-hams@trinnet.net>
Subject: Re: PATCH 1/1] AX.25: Close socket connection on session completion
Date: Mon, 4 Jul 2016 15:48:40 -0700
Message-ID: <577AE7C8.3040806@trinnet.net>
References: <20160616094230.1d023d0b@brox.localnet>
 <20160618.205545.1211200211643065140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jreuter@yaina.de, ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, basil@pacabunga.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20160618.205545.1211200211643065140.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello David,

Unless I'm doing something wrong, it seems this patch has only been 
applied to the newest
kernel:

    Git/linux-stable$ git tag -l --contains 
4a7d99ea1b27734558feb6833f180cd38a159940
    v4.7-rc6

How can we get this critical fix applied to the other stable kernel 
versions?  I would really hate
to depend on all the various Distro packagers to miss on picking this up 
as this is a critical
toxicity fix.


Reference: http://www.spinics.net/lists/linux-hams/msg03628.html

--David




On 06/18/2016 08:55 PM, David Miller wrote:
> From: Basil Gunn <basil@pacabunga.com>
> Date: Thu, 16 Jun 2016 09:42:30 -0700
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
> Applied.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-hams" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

