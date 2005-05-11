From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.4.30-hf1 do_IRQ stack overflows
Date: Thu, 12 May 2005 07:38:52 +1000
Message-ID: <E1DVyuq-0005Sf-00@gondolin.me.apana.org.au>
References: <20050511124640.GE8541@logos.cnet>
Cc: manfred99@gmx.ch, linux-kernel@vger.kernel.org, davem@redhat.com,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261260AbVEKVkr@vger.kernel.org>
To: marcelo.tosatti@cyclades.com (Marcelo Tosatti)
In-Reply-To: <20050511124640.GE8541@logos.cnet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
> May 11 04:22:09 server kernel:   [__switch_to+82/256] [schedule+738/1344] [schedule_timeout+84/160] [process_timeout+0/96] [st:__insmod_st_O/lib/modules/2.4.30-hf1/kernel/drivers/scsi/st+4294702743/96] [st:__insmod_st_O/lib/modules/2.4.30-hf1/kernel/drivers/scsi/st+4294703097/96]

The stack trace becomes unreadable at this point.  Please run klogd
with -X and then decode the messages with ksymoops.  Alternatively
run ksymoops on the output of dmesg directly.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
