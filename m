From: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Subject: Re: [TCP]: Fix truesize underflow
Date: Wed, 19 Apr 2006 10:04:53 +0400
Message-ID: <4445D305.8080505@kernelpanic.ru>
References: <20060418123204.GA3962@gondor.apana.org.au> <20060418.132256.110004342.davem@davemloft.net> <20060418232713.GA11938@gondor.apana.org.au>
Reply-To: bb@kernelpanic.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, kernel@linuxace.com,
	nipsy@bitgnome.net, jesse.brandeburg@intel.com,
	jrlundgren@gmail.com, cat@zip.com.au, djani22@dynamicweb.hu,
	yoseph.basri@gmail.com, mykleb@no.ibm.com, olel@ans.pl,
	michal@feix.cz, chris@scorpion.nl, netdev@vger.kernel.org,
	jesse.brandeburg@gmail.com, ak@suse.de, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.setcomm.ru ([83.102.151.194]:34260 "EHLO mail.setcomm.ru")
	by vger.kernel.org with ESMTP id S1750719AbWDSGFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 02:05:08 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060418232713.GA11938@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Herbert Xu.

On 19.04.2006 03:27 you said the following:

> On Tue, Apr 18, 2006 at 01:22:56PM -0700, David S. Miller wrote:
> 
>>I think it is deserving of some run time assertions, else these bugs
>>will elude us continually.  Luckily there are only a few places that
>>would need the run time assertion checks on skb->truesize, and I'll
>>try to spend a few cycles on implementing this soon.
> 
> 
> Yes indeed.  One place that comes to mind would be tcp_trim_head just
> before we munge truesize.
> 
> Cheers,


I confirm, finally I don't see messages in dmesg about assertions. Nice 
work :)

-- 
Boris B. Zhmurov
mailto: bb@kernelpanic.ru
"wget http://kernelpanic.ru/bb_public_key.pgp -O - | gpg --import"

