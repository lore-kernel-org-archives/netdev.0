From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] conntrack: use SLAB_DESTROY_BY_RCU for nf_conn structs
Date: Wed, 25 Mar 2009 19:06:31 +0100
Message-ID: <49CA72A7.8060805@trash.net>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se>	 <49C77D71.8090709@trash.net>	 <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se>	 <49C780AD.70704@trash.net>	 <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se>	 <49C7CB9B.1040409@trash.net>	 <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se>	 <49C8A415.1090606@cosmosbay.com>	 <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se>	 <49C8CCF4.5050104@cosmosbay.com> <1237907850.12351.80.camel@sakura.staff.proxad.net> <49C8FBCA.40402@cosmosbay.com> <49CA6F9A.9010806@cosmosbay.com> <49CA7255.20807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mbizon@freebox.fr, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49CA7255.20807@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
>> @@ -217,7 +218,7 @@ int nf_conntrack_helper_init(void)
>>  
>>      nf_ct_helper_hsize = 1; /* gets rounded up to use one page */
>>      nf_ct_helper_hash = nf_ct_alloc_hashtable(&nf_ct_helper_hsize,
>> -                          &nf_ct_helper_vmalloc);
>> +                          &nf_ct_helper_vmalloc, 0);
> 
> This should be "1" I think since it wants a hlist_nulls hash.

OK I just realized my mistake, please ignore :)
