From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 0/8] netfilter updates for net-next
Date: Fri, 16 Jan 2015 22:48:42 +0100
Message-ID: <54B9873A.4030201@hartkopp.net>
References: <1421267689-24894-1-git-send-email-pablo@netfilter.org> <20150115.015427.1217684585698382529.davem@davemloft.net> <54B97942.7090902@hartkopp.net> <20150116205434.GA2346@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150116205434.GA2346@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry Pablo!

I assumed this build error would finally have killed my WLAN.

But indeed it was the mac80211-next merge from Dave here:

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=27f097177defdd5858f03500e4b5aa8a97b1627b

I've already seen a fix from Johannes here (100 min ago):
http://git.kernel.org/cgit/linux/kernel/git/jberg/mac80211-next.git/commit/?id=57007121228347515187049a9c65f7cbeb923dd1

So I'll check that first.

Thanks,
Oliver

On 16.01.2015 21:54, Pablo Neira Ayuso wrote:
> On Fri, Jan 16, 2015 at 09:49:06PM +0100, Oliver Hartkopp wrote:
>> I get this problem at 'make module_install' time now:
>>
>> DEPMOD  3.19.0-rc4-nn-00578-g919d9db
>> depmod: WARNING: /lib/modules/3.19.0-rc4-nn-00578-g919d9db/updates/dkms/xt_DNETMAP.ko needs unknown symbol nf_nat_setup_info
>>
>> While 3.19.0-rc4-nn-00504-g4e7a84b was ok.
>>
>> Any idea?
> 
> I don't see any xt_DNETMAP target in my tree.
> 
